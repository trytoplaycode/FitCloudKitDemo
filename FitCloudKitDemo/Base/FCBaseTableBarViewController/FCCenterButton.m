//
//  FCCenterButton.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "FCCenterButton.h"
#import "FCDefinitions.h"

#define BULGEH 16

@implementation FCCenterButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
        
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectEqualToRect(self.frame, CGRectZero)) return;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.superview.frame.size.height;
    
    if (self.is_bulge) {
        self.imageView.frame = self.bounds;
        if (self.titleLabel.text.length) {
            self.titleLabel.frame = CGRectMake(0 , self.frame.size.height +(BULGEH-16)-kBottomOffset,
                                               self.frame.size.width , 16);
        }else {
            self.titleLabel.hidden = YES;
            self.imageView.frame = CGRectMake(0 , height-36-kBottomOffset, width, 47);
        }
        return;
    }

    if (!self.titleLabel.text.length) {
        self.imageView.frame = self.bounds;
        return;
    }

    self.titleLabel.frame = CGRectMake(0, height-BULGEH-kBottomOffset , width, BULGEH);
    self.imageView.frame = CGRectMake(0 , -kBottomOffset, width, 35);
}


- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
