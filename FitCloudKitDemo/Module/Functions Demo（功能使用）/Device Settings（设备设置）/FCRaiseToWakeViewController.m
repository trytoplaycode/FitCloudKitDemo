//
//  FCRaiseToWakeViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/25.
//

#import "FCRaiseToWakeViewController.h"
#import "FCDefinitions.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <BRPickerView/BRDatePickerView.h>

@interface FCRaiseToWakeViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchs;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;

@end

@implementation FCRaiseToWakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Raise to Wake Config", nil)];
    [self loadRaiseToWakeSettins];
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


- (void)loadRaiseToWakeSettins {
    [FitCloudKit getWristWakeUpSettingWithBlock:^(BOOL succeed, FitCloudWWUObject *wwuSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.switchs setOn:wwuSetting.on];
            [self.startButton setTitle:[self convertIntervalToTime:wwuSetting.begin] forState:UIControlStateNormal];
            [self.endButton setTitle:[self convertIntervalToTime:wwuSetting.end] forState:UIControlStateNormal];
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
    FitCloudWWUObject *settings = [FitCloudWWUObject new];
    settings.on = self.switchs.isOn;
    settings.begin = [self convertTimeToInterval:self.startButton.titleLabel.text];
    settings.end = [self convertTimeToInterval:self.endButton.titleLabel.text];
    __weak typeof(self) weakSelf = self;
    [FitCloudKit setWristWakeUp:settings block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
            [weakSelf loadRaiseToWakeSettins];
        });
    }];
}

@end
