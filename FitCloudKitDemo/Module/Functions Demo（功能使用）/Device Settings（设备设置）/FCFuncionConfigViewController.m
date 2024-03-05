//
//  FCFuncionConfigViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/24.
//

#import "FCFuncionConfigViewController.h"
#import "FCDefinitions.h"
#import <FitCloudKit/FitCloudKit.h>
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"

@interface FCFuncionConfigViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"function";

@implementation FCFuncionConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Function Config", nil)];
    [self initialization];
    [self loadWatchPrefer];
}

- (void)loadWatchPrefer {
    weakSelf(weakSelf);
    [FitCloudKit getFitCloudPreferWithBlock:^(BOOL succeed, FITCLOUDPREFER prefer, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FITCLOUDPREFER type = FITCLOUDPREFER_NONE;
            for (NSInteger i = 0; i < self.dataArr.count; i++) {
                FCCommenCellModel *model = weakSelf.dataArr[i];
                if (i == 0) {
                    type = FITCLOUDPREFER_RIGHTHAND;
                }else if (i == 1) {
                    type = FITCLOUDPREFER_ENHANCEDDETECTION;
                }else if (i == 2) {
                    type = FITCLOUDPREFER_SHOWAS12HOURS;
                }else if (i == 3) {
                    type = FITCLOUDPREFER_IMPERIALUNIT;
                }else if (i == 4) {
                    type = FITCLOUDPREFER_FAHRENHEIT;
                }else if (i == 5) {
                    type = FITCLOUDPREFER_WEATHERPUSH;
                }else if (i == 6) {
                    type = FITCLOUDPREFER_VIBRATEWHENDISCONNECT;
                }else if (i == 7) {
                    type = FITCLOUDPREFER_REMINDWHENSPORTSGOALACHIEVEMENT;
                }
                model.value = (prefer&type)== type ? @"1" : @"0";
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchAction:(UISwitch *)switchs {
    int index = (int)switchs.tag - 1000;
    FCCommenCellModel *model = self.dataArr[index];
    model.value = switchs.isOn ? @"1" : @"0";

    FITCLOUDPREFER value = FITCLOUDPREFER_NONE;
    BOOL select = NO;
    for (FCCommenCellModel *model in self.dataArr) {
        if ([model.value intValue] == 1) {
            select = YES;
            break;
        }
    }
    if (!select) {
        value = FITCLOUDPREFER_NONE;
    }
    
    int selectCount = 0;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        if ([model.value intValue] == 1) {
            if (i == 0) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_RIGHTHAND;
                }else {
                    value = value | FITCLOUDPREFER_RIGHTHAND;
                }
            }else if (i == 1) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_ENHANCEDDETECTION;
                }else {
                    value = value | FITCLOUDPREFER_ENHANCEDDETECTION;
                }
            }else if (i == 2) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_SHOWAS12HOURS;
                }else {
                    value = value | FITCLOUDPREFER_SHOWAS12HOURS;
                }
            }else if (i == 3) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_IMPERIALUNIT;
                }else {
                    value = value | FITCLOUDPREFER_IMPERIALUNIT;
                }
            }else if (i == 4) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_FAHRENHEIT;
                }else {
                    value = value | FITCLOUDPREFER_FAHRENHEIT;
                }
            }else if (i == 5) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_WEATHERPUSH;
                }else {
                    value = value | FITCLOUDPREFER_WEATHERPUSH;
                }
            }else if (i == 6) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_VIBRATEWHENDISCONNECT;
                }else {
                    value = value | FITCLOUDPREFER_VIBRATEWHENDISCONNECT;
                }
            }else if (i == 7) {
                if (selectCount == 0) {
                    value = FITCLOUDPREFER_REMINDWHENSPORTSGOALACHIEVEMENT;
                }else {
                    value = value | FITCLOUDPREFER_REMINDWHENSPORTSGOALACHIEVEMENT;
                }
            }
            
            selectCount += 1;
        }
    }
    
    [FitCloudKit setFitCloudPrefer:value block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
        });
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleSwitchs];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    [cell.switchs setOn:[model.value intValue] == 1 ? YES : NO];
    cell.switchs.tag = 1000 + indexPath.row;
    [cell.switchs addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Lazy
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

        NSArray *arr = @[NSLocalizedString(@"Right Hand Wearing", nil)
                         ,NSLocalizedString(@"Enhanced Measurement", nil),
                         NSLocalizedString(@"Time Format-12Hour", nil),
                         NSLocalizedString(@"Length Units-Imperial(miles,feet)", nil),
                         NSLocalizedString(@"Temperature Units-Fahrenheit(­°F)", nil),
                         NSLocalizedString(@"Display Weather", nil),
                         NSLocalizedString(@"Disconnect Reminder", nil),
                         NSLocalizedString(@"Display Exercise Goal", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}
@end
