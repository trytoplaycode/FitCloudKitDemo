//
//  FCAboutBraceletViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCAboutBraceletViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import <FitCloudKit/FitCloudKit.h>
#import "FCCommenCellModel.h"
#import "FCGlobal.h"
@interface FCAboutBraceletViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"about";
@implementation FCAboutBraceletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Bracelet Setting", nil)];
    [self setNavBackWhite];
    [self initialization];
    [self loadData];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [FitCloudKit getFirmwareVersionWithBlock:^(BOOL succeed, FitCloudFirmwareVersionObject *version, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FCCommenCellModel *model = weakSelf.dataArr[2];
            NSString *string = [NSString stringWithFormat:@"%@.%@.%@", [version.projectNo substringFromIndex:version.projectNo.length-3], [version.patchVersion substringFromIndex:version.patchVersion.length-4], [version.firmwareVersion substringFromIndex:version.firmwareVersion.length-3]];
            model.value = string;
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
    if (indexPath.row == 3) {
        [cell configCellStyle:FCCellStyleNormal];
    }else {
        [cell configCellStyle:FCCellStyleNone];
    }
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.valueLabel.text = model.value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {

        }
            break;
        case 3:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Factory Reset", nil) message:NSLocalizedString(@"Are you sure you want to reset factory settings", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [FitCloudKit restoreAsFactorySettingsWithBlock:^(BOOL succeed, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [FitCloudKit connect:[FCGlobal shareInstance].currentPeripheral];
                    });
                    NSLog(@"恢复出厂设置:%@", succeed ? @"成功" : @"失败");
                }];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:cancel];
            [alert addAction:sure];
            [self presentViewController:alert animated:YES completion:nil];
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
        NSArray *arr = @[NSLocalizedString(@"Device Name", nil),NSLocalizedString(@"Mac Address", nil),NSLocalizedString(@"Software Version", nil), NSLocalizedString(@"Factory Reset", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            model.value = @"";
            if (i == 0) {
                model.value = [FitCloudKit lastConnectPeripheral].name;
            }else if (i == 1) {
                model.value = [FitCloudKit macAddr];
            }
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}
@end

