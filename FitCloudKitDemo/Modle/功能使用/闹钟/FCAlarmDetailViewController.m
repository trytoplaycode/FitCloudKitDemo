//
//  FCAlarmListViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/26.
//

#import "FCAlarmDetailViewController.h"
#import "FCDefinitions.h"
#import <Toast.h>
#import <FitCloudKit/FitCloudKit.h>
#import <BRPickerView/BRDatePickerView.h>
#import "FCAlarmCycleViewController.h"
#import <NSDate+YYAdd.h>
#import "LocalizedButton.h"

@interface FCAlarmDetailViewController ()

@property (nonatomic, strong) FitCloudAlarmObject *model;
@property (weak, nonatomic) IBOutlet UISwitch *switchs;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleLabel;
@property (weak, nonatomic) IBOutlet UITextField *labelTextFeild;
@property (strong, nonatomic) __block NSDate *currentDate;
@property (weak, nonatomic) IBOutlet LocalizedButton *setButton;
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

static NSString *identifier = @"list";
@implementation FCAlarmDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.indexPath || self.model) {
        [self initialization];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [NSDateFormatter new];
    [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (self.indexPath) {
        self.model = self.dataArr[self.indexPath.row];
        [self addNavBar:self.model.label];
        [self initialization];
        [self.setButton setTitle:NSLocalizedString(@"Set", nil) forState:UIControlStateNormal];
    }else {
        self.model = [FitCloudAlarmObject new];
        self.model.on = YES;
        NSDate *timestamp = [NSDate date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:timestamp];
        self.model.fire = components;
        self.model.label = @"";
        self.model.cycle = FITCLOUDALARMCYCLE_NONE;
        [self addNavBar:NSLocalizedString(@"Add Alarm", nil)];
        [self.setButton setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    }
    self.timeLabel.userInteractionEnabled = YES;
    self.cycleLabel.userInteractionEnabled = YES;

}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.switchs setOn:self.model.on];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld-%ld-%ld %ld:%ld", self.model.fire.year, self.model.fire.month, self.model.fire.day, self.model.fire.hour, self.model.fire.minute];
    NSMutableString *cycle = @"".mutableCopy;
    if (self.model.cycle & FITCLOUDALARMCYCLE_NONE) {
        [cycle appendString:NSLocalizedString(@"Today", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_MON) {
        [cycle appendString:NSLocalizedString(@"Mon", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_TUE) {
        [cycle appendString:NSLocalizedString(@"Tue", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_WED) {
        [cycle appendString:NSLocalizedString(@"Wed", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_THUR) {
        [cycle appendString:NSLocalizedString(@"Thu", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_FRI) {
        [cycle appendString:NSLocalizedString(@"Fri", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_SAT) {
        [cycle appendString:NSLocalizedString(@"Sat", nil)];
        [cycle appendString:@"、"];
    }
    if (self.model.cycle & FITCLOUDALARMCYCLE_SUN) {
        [cycle appendString:NSLocalizedString(@"Sun", nil)];
        [cycle appendString:@"、"];
    }
    if (cycle.length > 0) {
        [cycle deleteCharactersInRange:NSMakeRange(cycle.length-1, 1)];
    }
    self.cycleLabel.text = cycle;
    self.labelTextFeild.text = self.model.label;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)timeAction:(id)sender {
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeYMDHM title:NSLocalizedString(@"Fire Date", nil) selectValue:self.timeLabel.text resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentDate = selectDate;
            self.timeLabel.text = selectValue;
        });
    }];
}

- (IBAction)cycleAction:(id)sender {
    FCAlarmCycleViewController *cycle = [FCAlarmCycleViewController new];
    cycle.model = self.model;
    [self.navigationController pushViewController:cycle animated:YES];
}

- (IBAction)setAction:(id)sender {
    if (self.currentDate) {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.year = self.currentDate.year;
        components.month = self.currentDate.month;
        components.day = self.currentDate.day;
        components.hour = self.currentDate.hour;
        components.minute = self.currentDate.minute;
        components.second = self.currentDate.second;
        self.model.fire = components;
    }
    self.model.label = self.labelTextFeild.text.length == 0 ? @"" : self.labelTextFeild.text;
    self.model.on = self.switchs.isOn;
    if (!self.indexPath) {
        [self.dataArr addObject:self.model];
    }
    [FitCloudKit setAlarms:self.dataArr block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
        });
    }];
}

@end
