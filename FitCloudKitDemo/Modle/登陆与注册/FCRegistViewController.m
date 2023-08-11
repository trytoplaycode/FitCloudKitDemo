//
//  FCRegistViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/12.
//

#import "FCRegistViewController.h"
#import <YYModel.h>
#import <FitCloudKit/FitCloudKit.h>
#import "FCDefinitions.h"

@interface FCRegistViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *heightTF;
@property (weak, nonatomic) IBOutlet UITextField *weightTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegment;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UIButton *registButton;

@end

@implementation FCRegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBackWhite];
    self.passwordTF.secureTextEntry = YES;
    self.heightTF.keyboardType = UIKeyboardTypeNumberPad;
    self.weightTF.keyboardType = UIKeyboardTypeNumberPad;
    self.ageTF.keyboardType = UIKeyboardTypePhonePad;
    [self addNavBar:NSLocalizedString(@"Sign Up", nil)];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)registAction:(id)sender {
    [self.view endEditing:YES];
    if (self.userNameTF.text.length == 0 || self.passwordTF.text.length == 0 || self.heightTF.text.length == 0 || self.weightTF.text.length == 0 || self.ageTF.text.length == 0) {
        return;
    }
    FitCloudUserProfileObject *model = [FitCloudUserProfileObject new];
    model.gender = self.sexSegment.selectedSegmentIndex == 0 ? FITCLOUDGENDER_FEMALE : FITCLOUDGENDER_MALE;
    model.age = [self.ageTF.text intValue];
    model.height = [self.heightTF.text floatValue];
    model.weight = [self.weightTF.text floatValue];
    NSString *modelString = [model yy_modelToJSONString];
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInfoList];
    NSMutableDictionary *muta = info ? info.mutableCopy : @{}.mutableCopy;
    [muta setObject:modelString?:@"" forKey:self.userNameTF.text];
    [[NSUserDefaults standardUserDefaults] setObject:muta forKey:kUserInfoList];
    NSDictionary *account = @{self.userNameTF.text: self.passwordTF.text?:@""};
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:kUserNameAndPwd];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
