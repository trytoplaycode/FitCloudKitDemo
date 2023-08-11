//
//  FCHisoryListViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/30.
//

#import "FCHisoryListViewController.h"
#import "FCDefinitions.h"
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import "FCHistoryDataViewController.h"

@interface FCHisoryListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"list";
@implementation FCHisoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"History Data", nil)];
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
    FCHistoryDataViewController *history = [FCHistoryDataViewController new];
    if (indexPath.row == 0) {
        history.type = FCHistoryTypeStep;
    }else if (indexPath.row == 1) {
        history.type = FCHistoryTypeHeartRate;
    }else if (indexPath.row == 2) {
        history.type = FCHistoryTypeBloodOxygen;
    }else if (indexPath.row == 3) {
        history.type = FCHistoryTypeBloodPressure;
    }else if (indexPath.row == 4) {
        history.type = FCHistoryTypeSleep;
    }else if (indexPath.row == 5) {
        history.type = FCHistoryTypeSports;
    }
    history.titleString = self.dataArr[indexPath.row];
    [self.navigationController pushViewController:history animated:YES];
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
        NSArray *arr = @[NSLocalizedString(@"Steps", nil),NSLocalizedString(@"Heart Rate", nil),NSLocalizedString(@"Blood Oxygen", nil),NSLocalizedString(@"Blood Pressure", nil),NSLocalizedString(@"Sleep", nil),NSLocalizedString(@"Sports", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            [_dataArr addObject:arr[i]];
        }
    }
    
    return _dataArr;
}

@end
