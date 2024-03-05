//
//  FCBaseViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "FCBaseViewController.h"
#import "FCDefinitions.h"

@interface FCBaseViewController ()

@property (nonatomic, strong) UILabel *navTitleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation FCBaseViewController

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self baseInitialization];
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    [self setNavBackWhite];
}

- (void)baseInitialization {
    [self baseAddSubViews];
    [self baseLayout];
}

- (void)baseAddSubViews {
    [self.view addSubview:self.navBackView];
    [self.navBackView addSubview:self.navTitleLabel];
    [self.navBackView addSubview:self.backButton];
    [self.navBackView addSubview:self.bottomLine];
}

- (void)layout {
    
}

- (void)baseLayout {
    
}

- (void)setNavBarClear {
//    self.navBackView.backgroundColor = [UIColor clearColor];
    self.navBackView.hidden = YES;
}

- (void)addNavBar:(NSString *)title {
    self.navTitleLabel.text = title;
}

- (void)setNavBackWhite {
    [self.backButton setImage:IMAGENAME(@"back") forState:UIControlStateNormal];
    self.navTitleLabel.textColor = [UIColor whiteColor];
    [self.rightButton setTitleColor:UIColorWithRGB(0xffffff, 1.f) forState:UIControlStateNormal];
}

- (void)addNavRightButton:(NSString *)right isImage:(BOOL)isImage {
    [self.navBackView addSubview:self.rightButton];
    if (isImage) {
        [self.rightButton setImage:IMAGENAME(right) forState:UIControlStateNormal];
    }else {
        [self.rightButton setTitle:right forState:UIControlStateNormal];
    }
}

- (void)addNavRightViewWithView:(UIView *)rightView {
    self.rightButton.hidden = YES;
    [self.navBackView addSubview:rightView];
}
- (void)initialization {
    
}
#pragma mark - Action
- (void)backAction {
    
}

- (void)rightButtonAction {
    
}

#pragma mark - Setter & Getter
- (void)setNeedBack:(BOOL)needBack {
    _needBack = needBack;
    self.backButton.hidden = !needBack;
}

- (void)setNeedBottomLine:(BOOL)needBottomLine {
    _needBottomLine = needBottomLine;
    self.bottomLine.hidden = !_needBottomLine;
}

#pragma mark - Lazy
- (UIView *)navBackView {
    if (!_navBackView) {
        _navBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopBarHeight)];
        _navBackView.backgroundColor = [UIColor colorWithRed:77/256.f green:90/256.f blue:187/256.f alpha:1.f];
//        _navBackView.backgroundColor = [UIColor whiteColor];
    }
    
    return _navBackView;
}

- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.f-ScaleW(100), kStatusBarHeight, ScaleW(200), kTopBarHeight-kStatusBarHeight)];
        _navTitleLabel.textColor = UIColorWithRGB(0xffffff, 1.f);
        _navTitleLabel.font = FONT_MEDIUM(18);
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _navTitleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(7, kStatusBarHeight+2, 40, 40);
        [_backButton setImage:IMAGENAME(@"back_icon_2") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(kScreenWidth-90, kStatusBarHeight+11, 70, 22);
        _rightButton.titleLabel.font = FONT_REGULAR(16);
        [_rightButton setTitleColor:UIColorWithRGB(0x7598FF, 1.f) forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _rightButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, kTopBarHeight-1, kScreenWidth, 1)];
        _bottomLine.backgroundColor = UIColorWithRGB(0xf9f9f9, 1.f);
        _bottomLine.hidden = YES;
    }
    
    return _bottomLine;
}


@end
