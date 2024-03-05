//
//  DNDSettingViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/25.
//

#import "DNDSettingViewController.h"
#import "FCDefinitions.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <BRPickerView/BRDatePickerView.h>

@interface DNDSettingViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchs;
@property (weak, nonatomic) IBOutlet UISwitch *periodSwitchs;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;

@end

@implementation DNDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"DND Config", nil)];
    [self loadDNDSettins];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)convertIntervalToTime:(UInt16)interval {
    int hour = interval/60;
    int min = interval%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", hour, min];
}

- (int)convertTimeToInterval:(NSString *)time {
    NSArray *arr = [time componentsSeparatedByString:@":"];
    if (arr.count != 2) {return 0;}
    NSString *hour = [arr firstObject];
    NSString *min = [arr lastObject];
    
    return [hour intValue]*60+[min intValue];
}


- (void)loadDNDSettins {
    [FitCloudKit getDNDSettingWithBlock:^(BOOL succeed, FitCloudDNDSetting *dndSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.switchs setOn:dndSetting.on];
            [self.periodSwitchs setOn:dndSetting.dndPeriodOn];
            [self.startButton setTitle:[self convertIntervalToTime:dndSetting.periodBegin] forState:UIControlStateNormal];
            [self.endButton setTitle:[self convertIntervalToTime:dndSetting.periodEnd] forState:UIControlStateNormal];
        });
    }];
}

- (IBAction)startAction:(id)sender {
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeHM title:NSLocalizedString(@"Start Time", nil) selectValue:self.startButton.titleLabel.text resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        [self.startButton setTitle:selectValue forState:UIControlStateNormal];
    }];
}

- (IBAction)endAction:(id)sender {
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeHM title:NSLocalizedString(@"End Time", nil) selectValue:self.endButton.titleLabel.text resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        int startTime = [self convertTimeToInterval:self.startButton.titleLabel.text];
        int endTime = [self convertTimeToInterval:selectValue];
        if (endTime < startTime) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:NSLocalizedString(@"The end time cannot be less than the start time", nil)];
            });
        }else {
            [self.endButton setTitle:selectValue forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)setAction:(id)sender {
    FitCloudDNDSetting *settings = [FitCloudDNDSetting new];
    settings.on = self.switchs.isOn;
    settings.dndPeriodOn = self.periodSwitchs.isOn;
    settings.periodBegin = [self convertTimeToInterval:self.startButton.titleLabel.text];
    settings.periodEnd = [self convertTimeToInterval:self.endButton.titleLabel.text];
    __weak typeof(self) weakSelf = self;
    [FitCloudKit setDND:settings block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
            [weakSelf loadDNDSettins];
        });
    }];
}

@end
