//
//  FCDrinkWaterReminderViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/25.
//

#import "FCDrinkWaterReminderViewController.h"
#import "FCDefinitions.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <BRPickerView/BRDatePickerView.h>
#import <BRPickerView/BRStringPickerView.h>

@interface FCDrinkWaterReminderViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchs;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *intervalButton;
@property (weak, nonatomic) IBOutlet UIButton *setButton;

@end

@implementation FCDrinkWaterReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Drink Water Reminder Config", nil)];
    [self loadDrinkWaterSettings];
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

- (void)loadDrinkWaterSettings {
    [FitCloudKit getDrinkRemindSettingWithBlock:^(BOOL succeed, FitCloudDRObject *drSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.switchs setOn:drSetting.on];
            [self.startButton setTitle:[self convertIntervalToTime:drSetting.begin] forState:UIControlStateNormal];
            [self.endButton setTitle:[self convertIntervalToTime:drSetting.end] forState:UIControlStateNormal];
            [self.intervalButton setTitle:[NSString stringWithFormat:@"%d", drSetting.interval] forState:UIControlStateNormal];
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

- (IBAction)intervalAction:(id)sender {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 24*60; i++) {
        [arr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [BRStringPickerView showPickerWithTitle:NSLocalizedString(@"Interval", nil) dataSourceArr:arr selectIndex:[self.intervalButton.titleLabel.text integerValue] resultBlock:^(BRResultModel * _Nullable resultModel) {
        [self.intervalButton setTitle:resultModel.value forState:UIControlStateNormal];
    }];
}

- (IBAction)setAction:(id)sender {
    FitCloudDRObject *settings = [FitCloudDRObject new];
    settings.on = self.switchs.isOn;
    settings.interval = [self.intervalButton.titleLabel.text integerValue];
    settings.begin = [self convertTimeToInterval:self.startButton.titleLabel.text];
    settings.end = [self convertTimeToInterval:self.endButton.titleLabel.text];
    __weak typeof(self) weakSelf = self;
    [FitCloudKit setDrinkRemind:settings block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
            [weakSelf loadDrinkWaterSettings];
        });
    }];
}

@end
