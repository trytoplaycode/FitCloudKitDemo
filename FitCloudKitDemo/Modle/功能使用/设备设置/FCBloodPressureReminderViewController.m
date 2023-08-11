//
//  FCBloodPressureReminderViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/25.
//

#import "FCBloodPressureReminderViewController.h"
#import "FCDefinitions.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <BRPickerView/BRStringPickerView.h>

@interface FCBloodPressureReminderViewController ()
@property (nonatomic, strong) FitCloudBPRObject *dbpModel;
@property (weak, nonatomic) IBOutlet UISwitch *switchs;
@property (weak, nonatomic) IBOutlet UIButton *diastolicButton;
@property (weak, nonatomic) IBOutlet UIButton *systolicButton;
@property (weak, nonatomic) IBOutlet UIButton *setButton;

@end

@implementation FCBloodPressureReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Blood Pressure Reference Config", nil)];
    [self loadBloodPressSettings];
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBloodPressSettings {
    [FitCloudKit getBloodPressureReferSettingWithBlock:^(BOOL succeed, FitCloudBPRObject *dbpSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dbpModel = dbpSetting;
            [self.switchs setOn:dbpSetting.on];
            [self.diastolicButton setTitle:[NSString stringWithFormat:@"%d", dbpSetting.diastolic] forState:UIControlStateNormal];
            [self.systolicButton setTitle:[NSString stringWithFormat:@"%d", dbpSetting.systolic] forState:UIControlStateNormal];
        });
    }];
}

- (IBAction)diastolicAction:(id)sender {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 300; i++) {
        [arr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [BRStringPickerView showPickerWithTitle:NSLocalizedString(@"Diastolic", nil) dataSourceArr:arr selectIndex:[self.diastolicButton.titleLabel.text integerValue] resultBlock:^(BRResultModel * _Nullable resultModel) {
        [self.diastolicButton setTitle:resultModel.value forState:UIControlStateNormal];
//        self.dbpModel.diastolic = [resultModel.value intValue];
//        [FitCloudKit setBloodPressureRefer:self.dbpModel block:^(BOOL succeed, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                OpResultToastTip(self.view, succeed);
//            });
//        }];
    }];
}

- (IBAction)systolicAction:(id)sender {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 300; i++) {
        [arr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [BRStringPickerView showPickerWithTitle:NSLocalizedString(@"Systolic", nil) dataSourceArr:arr selectIndex:[self.systolicButton.titleLabel.text integerValue] resultBlock:^(BRResultModel * _Nullable resultModel) {
        [self.systolicButton setTitle:resultModel.value forState:UIControlStateNormal];
//        self.dbpModel.systolic = [resultModel.value intValue];
//        [FitCloudKit setBloodPressureRefer:self.dbpModel block:^(BOOL succeed, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                OpResultToastTip(self.view, succeed);
//            });
//        }];
    }];
}

- (IBAction)setAction:(id)sender {
    FitCloudBPRObject *settings = [FitCloudBPRObject new];
    settings.on = self.switchs.isOn;
    settings.diastolic = [self.diastolicButton.titleLabel.text intValue];
    settings.systolic = [self.systolicButton.titleLabel.text intValue];
    [FitCloudKit setBloodPressureRefer:settings block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeed) {
                OpResultToastTip(self.view, succeed);
                [self loadBloodPressSettings];
            }
        });
    }];
}

@end
