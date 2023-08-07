//
//  FCAlarmListViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/26.
//

#import "FCAlarmListViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import "FCAlarmDetailViewController.h"
#import <FitCloudKit/FitCloudKit.h>
@interface FCAlarmListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"list";
@implementation FCAlarmListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Alarm List", nil)];
    [self initialization];
    [self loadAlarmList];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
}

- (void)loadAlarmList {
    __weak typeof(self) weakSelf = self;
    [FitCloudKit getAlarmsWithBlock:^(BOOL succeed, NSArray<FitCloudAlarmObject *> *list, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArr removeAllObjects];
            [weakSelf.dataArr addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
        });
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:NO];
    FitCloudAlarmObject *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.label;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCAlarmDetailViewController *detail = [FCAlarmDetailViewController new];
    detail.model = self.dataArr[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
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
    }
    
    return _dataArr;
}
@end
