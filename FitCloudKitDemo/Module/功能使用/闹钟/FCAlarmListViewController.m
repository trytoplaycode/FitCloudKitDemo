//
//  FCAlarmDetailViewController.m
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
@property (nonatomic, strong) UIButton *sureButton;

@end

static NSString *identifier = @"list";
@implementation FCAlarmListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAlarmList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Alarm List", nil)];
    [self initialization];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
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

- (void)addAction {
    if (self.dataArr.count >= 5) {
        [self.view makeToast:NSLocalizedString(@"Allow up to 5 alarm clocks to be set", nil)];
        return;
    }
    FCAlarmDetailViewController *detail = [FCAlarmDetailViewController new];
    detail.dataArr = self.dataArr;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleNormal];
    FitCloudAlarmObject *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.label;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCAlarmDetailViewController *detail = [FCAlarmDetailViewController new];
    detail.dataArr = self.dataArr;
    detail.indexPath = indexPath;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-100)];
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

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth-100, 50);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:NSLocalizedString(@"Add Alarm", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}
@end
