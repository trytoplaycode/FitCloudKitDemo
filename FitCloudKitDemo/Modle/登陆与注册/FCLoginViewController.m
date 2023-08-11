//
//  FCLoginViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "FCLoginViewController.h"
#import "FCDefinitions.h"
#import <Masonry/Masonry.h>
#import "FCRegistViewController.h"
#import <YYModel.h>
#import <FitCloudKit/FitCloudKit.h>
#import "FCDeviceBindViewController.h"
@interface FCLoginViewController ()

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *pwdTF;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) UIButton *registButton;

@end

@implementation FCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pwdTF.secureTextEntry = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavBar];
    [self initialization];
}

- (void)setNavBar {
    [self addNavBar:NSLocalizedString(@"Sign In", nil)];
}

- (void)initialization {
    [self addSubViews];
    [self layout];
}

- (void)addSubViews {
    [self.view addSubview:self.userNameTF];
    [self.view addSubview:self.pwdTF];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.registButton];
}

- (void)layout {
    [self.userNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(50);
        make.right.mas_equalTo(self.view.mas_right).offset(-50);
        make.top.mas_equalTo(self.view.mas_top).offset(180);
        make.height.mas_equalTo(50);
    }];
    [self.pwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(50);
        make.right.mas_equalTo(self.view.mas_right).offset(-50);
        make.top.mas_equalTo(self.userNameTF.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
    }];
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(50);
        make.right.mas_equalTo(self.view.mas_right).offset(-50);
        make.top.mas_equalTo(self.pwdTF.mas_bottom).offset(30);
        make.height.mas_equalTo(50);
    }];
    [self.registButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(self.sureButton.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userNameTF endEditing:YES];
    [self.pwdTF endEditing:YES];
}

#pragma mark - 点击事件
- (void)signInAction {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameAndPwd];
    if ([info.allKeys containsObject:self.userNameTF.text]) {
        if ([[info objectForKey:self.userNameTF.text] isEqualToString:self.pwdTF.text]) {
            FCDeviceBindViewController *bind = [FCDeviceBindViewController new];
            [self.navigationController pushViewController:bind animated:YES];
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:kLoginFlag];
        }else {
            //"Account password mismatch" = "Account password mismatch";
        }
    }
}

- (void)registAction {
    [self.navigationController pushViewController:[FCRegistViewController new] animated:YES];
}

#pragma mark - 懒加载
- (UITextField *)userNameTF {
    if (!_userNameTF) {
        _userNameTF = [[UITextField alloc] init];
        _userNameTF.textColor = UIColorWithRGB(0x666666, 1.f);
        _userNameTF.font = FONT_REGULAR(16);
        _userNameTF.placeholder = NSLocalizedString(@"Input username", nil);;
        
        UIView *line = [UIView new];
        line.backgroundColor = UIColorWithRGB(0xe0e0e0, 1.f);
        [_userNameTF addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_userNameTF);
            make.height.mas_equalTo(ScaleW(1));
        }];
    }
    
    return _userNameTF;
}

- (UITextField *)pwdTF {
    if (!_pwdTF) {
        _pwdTF = [[UITextField alloc] init];
        _pwdTF.textColor = UIColorWithRGB(0x666666, 1.f);
        _pwdTF.font = FONT_REGULAR(16);
        _pwdTF.placeholder = NSLocalizedString(@"Input password", nil);
        
        UIView *line = [UIView new];
        line.backgroundColor = UIColorWithRGB(0xe0e0e0, 1.f);
        [_pwdTF addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_pwdTF);
            make.height.mas_equalTo(ScaleW(1));
        }];
    }
    
    return _pwdTF;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.backgroundColor = self.navBackView.backgroundColor;
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        [_sureButton setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(signInAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}

- (UIButton *)registButton {
    if (!_registButton) {
        _registButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registButton setTitleColor:UIColorWithRGB(0x666666, 1.f) forState:UIControlStateNormal];
        _registButton.titleLabel.font = FONT_REGULAR(13);
        [_registButton addTarget:self action:@selector(registAction) forControlEvents:UIControlEventTouchUpInside];
        NSString *string = NSLocalizedString(@"No account?", nil);
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:string];
        [attribute addAttributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:NSMakeRange(0, string.length)];
        [_registButton setAttributedTitle:attribute forState:UIControlStateNormal];
    }
    
    return _registButton;
}
@end

