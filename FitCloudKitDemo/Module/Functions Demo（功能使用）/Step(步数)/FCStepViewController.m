//
//  FCStepViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCStepViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import "FCTodySportsDataViewController.h"
#import "FCStepTargetViewController.h"
#import "FCGlobal.h"

@interface FCStepViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"step";
@implementation FCStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Step", nil)];
    [self initialization];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
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
    if (![FitCloudKit deviceReady]) {
        [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
        return;
    }
    switch (indexPath.row) {
        case 0:
        {
            FCTodySportsDataViewController *today = [FCTodySportsDataViewController new];
            [self.navigationController pushViewController:today animated:YES];
        }
            break;
        case 1:
        {
            FCStepTargetViewController *target = [FCStepTargetViewController new];
            [self.navigationController pushViewController:target animated:YES];
        }
            break;
        default:
            break;
    }
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
        _dataArr = @[NSLocalizedString(@"Get Sports Data Today", nil), NSLocalizedString(@"Step Target", nil)].mutableCopy;
    }
    
    return _dataArr;
}
@end
