//
//  FCTabbar.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "FCTabbar.h"
#import "FCDefinitions.h"
#import "FCButton.h"
#import "FCCenterButton.h"

#define BULGEH 16
@interface FCTabbar ()

@property (weak , nonatomic) FCButton *selButton;

@property(assign , nonatomic) NSInteger centerPlace;

@property(assign , nonatomic,getter=is_bulge) BOOL bulge;

@property (weak , nonatomic) UITabBarController *controller;

@property (nonatomic,weak) CAShapeLayer *border;

@end

@implementation FCTabbar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UIImage *newImage = IMAGENAME(@"tabbar_back");
        newImage = [newImage resizableImageWithCapInsets:UIEdgeInsetsMake(newImage.size.height*0.5, 0, newImage.size.height*0.5, 0) resizingMode:UIImageResizingModeStretch];
        self.image = newImage;
        self.btnArr = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setItems:(NSArray<UITabBarItem *> *)items {
    _items = items;
    for (int i = 0; i < items.count; i++) {
        UITabBarItem *item = items[i];
        UIButton *btn = nil;
        if (self.centerPlace != -1 && self.centerPlace == i) {
            self.centerBtn = [FCCenterButton buttonWithType:UIButtonTypeCustom];
            self.centerBtn.adjustsImageWhenHighlighted = NO;
            self.centerBtn.bulge = self.is_bulge;
            btn = self.centerBtn;
            if (item.tag == -1) {
                [btn addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [btn addTarget:self action:@selector(controlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
        } else {
            btn = [FCButton buttonWithType:UIButtonTypeCustom];
            //Add Observer
            [item addObserver:self forKeyPath:@"badgeValue"
                      options:NSKeyValueObservingOptionNew
                      context:(__bridge void * _Nullable)(btn)];
            [item addObserver:self forKeyPath:@"badgeColor"
                      options:NSKeyValueObservingOptionNew
                      context:(__bridge void * _Nullable)(btn)];
            btn.tag = 4320+i;
            [self.btnArr addObject:(FCButton *)btn];
            [btn addTarget:self action:@selector(controlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //Set image
        [btn setImage:item.image forState:UIControlStateNormal];
        [btn setImage:item.selectedImage forState:UIControlStateSelected];
        btn.adjustsImageWhenHighlighted = NO;
        
        //Set title
        [btn setTitle:item.title forState:UIControlStateNormal];
        [btn setTitleColor:UIColorWithRGB(0xABABAB, 1.f) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorWithRGB(0xfdcd00, 1.f) forState:UIControlStateSelected];
        btn.titleLabel.font = FONT_REGULAR(10);

        btn.tag = item.tag;
        [self addSubview:btn];
        if (i == 0) {
            self.selButton = (FCButton *)btn;
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    int count = (int)(self.centerBtn ? self.btnArr.count+1 : self.btnArr.count);
    int mid = count/2;
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width/count,self.bounds.size.height);
    int j = 0;
    
    for (int i=0; i<count; i++) {
        if (i == mid && self.centerBtn!= nil) {
            CGFloat h = self.items[self.centerPlace].title ? 10.f : 0;
            CGFloat radius = 10.f;
            self.centerBtn.frame = self.is_bulge
            ? CGRectMake(rect.origin.x+(rect.size.width-rect.size.height-radius)/2,
                         -BULGEH-h,
                         rect.size.height+radius,
                         rect.size.height+radius)
            : rect;
        } else {
            self.btnArr[j++].frame = rect;
        }
        rect.origin.x += rect.size.width;
    }
}

- (void)setBrigdAtIndex:(NSInteger)index {
    FCButton *btn = self.btnArr[index];
    UIView *brigd = [btn viewWithTag:1000+index];
    if (brigd) {
        brigd.hidden = NO;
    }else {
        CGFloat width = self.bounds.size.width/3.f;
        UIView *brigd = [[UIView alloc] initWithFrame:CGRectMake(width/2.f+10, self.bounds.size.height/2.f-7, 9, 9)];
        brigd.backgroundColor = [UIColor redColor];
        brigd.clipsToBounds = YES;
        brigd.layer.cornerRadius = 4.5;
        brigd.tag = 1000+index;
        [btn addSubview:brigd];
    }
}

- (void)hiddenBrigdAtIndex:(NSInteger)index {
    FCButton *btn = [self viewWithTag:index];
    UIView *brigd = [btn viewWithTag:1000+index];
    brigd.hidden = YES;
}
#pragma mark - 点击事件处理
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = self.centerBtn.frame;
    if (CGRectContainsPoint(rect, point))
        return self.centerBtn;
    return [super hitTest:point withEvent:event];
}

#pragma mark - Button actions
- (void)controlBtnClick:(FCButton *)button {
//    if (![FFMasterInfoManager getAppToken] && button.tag == 2) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"personalCenterClickNoti" object:nil];
//        return;
//    }
//    if (self.selectButtoIndex == 0 && button.tag == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollToTopNoti" object:nil];
//    }
    self.selButton.titleLabel.font = FONT_REGULAR(10);
    self.controller.selectedIndex = button.tag;
    [self setSelectButtoIndex:button.tag];
}

- (void)centerBtnClick:(FCCenterButton *)button {
    if (self.centerButtonCallback) {
        self.centerButtonCallback();
    }
}

#pragma mark - Setter & Getter
- (void)setSelectButtoIndex:(NSUInteger)index {
    _selectButtoIndex = index;
    for (FCButton *loop in self.btnArr) {
        if (loop.tag == index) {
            self.selButton = loop;
            break;;
        }
    }
    self.selButton.titleLabel.font = FONT_MEDIUM(11);
//    if (index == self.centerBtn.tag) {
//        self.selButton = (PAButton *)self.centerBtn;
//    }
}


- (void)setSelButton:(FCButton *)selButton {
    _selButton.selected = NO;
    _selButton = selButton;
    _selButton.selected = YES;
}

- (void)setTextColor:(UIColor *)textColor {
    for (UIButton *loop in self.btnArr) {
        [loop setTitleColor:textColor forState:UIControlStateNormal];
    }
    
    _textColor = textColor;
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    for (UIButton *loop in self.btnArr) {
        [loop setTitleColor:selectedTextColor forState:UIControlStateSelected];
    }
    _selectedTextColor = selectedTextColor;
}


- (CAShapeLayer *)border {
    if (!_border) {
        CAShapeLayer *border = [CAShapeLayer layer];
        border.fillColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
        border.path = [UIBezierPath bezierPathWithRect:
                       CGRectMake(0,0,self.bounds.size.width,0.5)].CGPath;
        [self.layer insertSublayer:border atIndex:0];
        _border = border;
    }
    return _border;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"badgeValue"] || [keyPath isEqualToString:@"badgeColor"]) {
        FCButton *btn = (__bridge FCButton *)(context);
        btn.item = (UITabBarItem*)object;
    }
}

#pragma - dealloc
- (void)dealloc {
    for (int i=0; i<self.btnArr.count; i++) {
        int index = ({
            int n = 0;
            if (-1 != _centerPlace)
                n = _centerPlace > i ? 0 : 1;
            i+n;});
        [self.items[index] removeObserver:self
                               forKeyPath:@"badgeValue"
                                  context:(__bridge void * _Nullable)(self.btnArr[i])];
        [self.items[index] removeObserver:self
                               forKeyPath:@"badgeColor"
                                  context:(__bridge void * _Nullable)(self.btnArr[i])];
    }
}

@end
