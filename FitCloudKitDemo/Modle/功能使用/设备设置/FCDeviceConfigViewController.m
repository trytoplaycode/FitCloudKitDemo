//
//  FCDeviceConfigViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/24.
//

#import "FCDeviceConfigViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import "FCStepViewController.h"
#import "FCAboutBraceletViewController.h"
#import "FCMessageNotifyViewController.h"
#import "FCFuncionConfigViewController.h"
#import "FCHealthMonitorSettingViewController.h"
#import "FCSedentaryReminderViewController.h"
#import "FCDrinkWaterReminderViewController.h"
#import "FCBloodPressureReminderViewController.h"
#import "FCRaiseToWakeViewController.h"
#import "DNDSettingViewController.h"

@interface FCDeviceConfigViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"config";
@implementation FCDeviceConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Device Config", nil)];
    [self setNavBackWhite];
    [self initialization];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleNormal];
    cell.nameLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            FCMessageNotifyViewController *notify = [FCMessageNotifyViewController new];
            [self.navigationController pushViewController:notify animated:YES];
        }
            break;
        case 1:
        {
            FCFuncionConfigViewController *func = [FCFuncionConfigViewController new];
            [self.navigationController pushViewController:func animated:YES];
        }
            break;
        case 2:
        {
            FCHealthMonitorSettingViewController *health = [FCHealthMonitorSettingViewController new];
            [self.navigationController pushViewController:health animated:YES];
        }
            break;
        case 3:
        {
            FCSedentaryReminderViewController *sedentary = [FCSedentaryReminderViewController new];
            [self.navigationController pushViewController:sedentary animated:YES];
        }
            break;
        case 4:
        {
            FCDrinkWaterReminderViewController *drink = [FCDrinkWaterReminderViewController new];
            [self.navigationController pushViewController:drink animated:YES];
        }
            break;
        case 5:
        {
            FCBloodPressureReminderViewController *blood = [FCBloodPressureReminderViewController new];
            [self.navigationController pushViewController:blood animated:YES];
        }
            break;
        case 6:
        {
            FCRaiseToWakeViewController *raise = [FCRaiseToWakeViewController new];
            [self.navigationController pushViewController:raise animated:YES];
        }
            break;
        case 7:
        {
            DNDSettingViewController *dnd = [DNDSettingViewController new];
            [self.navigationController pushViewController:dnd animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[FCFuncListTableViewCell class] forCellReuseIdentifier:identifier];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
        [_dataArr addObject:NSLocalizedString(@"Notification Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Function Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Health Monitor Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Sedentary Reminder Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Drink Water Reminder Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Blood Pressure Reference Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Raise to Wake Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"DND Config", nil)];
    }
    
    return _dataArr;
}
@end
