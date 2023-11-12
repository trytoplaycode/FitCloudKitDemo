//
//  FCSedentaryReminderViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/25.
//

#import "FCSedentaryReminderViewController.h"
#import "FCDefinitions.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <BRPickerView/BRDatePickerView.h>

@interface FCSedentaryReminderViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchs;
@property (weak, nonatomic) IBOutlet UISwitch *lunchSwitchs;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;

@end

@implementation FCSedentaryReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Sedentary Reminder Config", nil)];
    [self loadSedentaryReminderSettings];
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

- (void)loadSedentaryReminderSettings {
    [FitCloudKit getSedentaryRemindSettingWithBlock:^(BOOL succeed, FitCloudLSRObject *lsrSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.switchs setOn:lsrSetting.on];
            [self.lunchSwitchs setOn:lsrSetting.offWhenLunchBreak];
            [self.startButton setTitle:[self convertIntervalToTime:lsrSetting.begin] forState:UIControlStateNormal];
            [self.endButton setTitle:[self convertIntervalToTime:lsrSetting.end] forState:UIControlStateNormal];
        });
    }];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startAction:(id)sender {
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeHM title:NSLocalizedString(@"Start Time", nil) selectValue:self.startButton.titleLabel.text resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        [self.startButton setTitle:selectValue forState:UIControlStateNormal];
    }];
}

- (IBAction)endAction:(id)sender {
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeHM title:NSLocalizedString(@"Etart Time", nil) selectValue:self.endButton.titleLabel.text resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
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
    FitCloudLSRObject *settings = [FitCloudLSRObject new];
    settings.on = self.switchs.isOn;
    settings.offWhenLunchBreak = self.lunchSwitchs.isOn;
    settings.begin = [self convertTimeToInterval:self.startButton.titleLabel.text];
    settings.end = [self convertTimeToInterval:self.endButton.titleLabel.text];
    __weak typeof(self) weakSelf = self;
    [FitCloudKit setSedentaryRemind:settings block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
            [weakSelf loadSedentaryReminderSettings];
        });
    }];
}

@end
