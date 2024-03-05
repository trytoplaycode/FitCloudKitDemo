//
//  FCMessageNotifyViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCMessageNotifyViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import <FitCloudKit/FitCloudKit.h>
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"

@interface FCMessageNotifyViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

static NSString *identifier = @"notify";
@implementation FCMessageNotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Notification Config", nil)];
    [self setNavBackWhite];
    [self initialization];
    [self loadNotifyStatus];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadNotifyStatus {
    __weak typeof(self) weakSelf = self;
    [FitCloudKit getMessageNotificationSettingWithBlock:^(BOOL succeed, FITCLOUDMN mnSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FITCLOUDMN type = FITCLOUDMN_NONE;
            for (NSInteger i = 0; i < self.dataArr.count; i++) {
                FCCommenCellModel *model = weakSelf.dataArr[i];
                if (i == 0) {
                    type = FITCLOUDMN_CALL;
                }else if (i == 1) {
                    type = FITCLOUDMN_SMS;
                }else if (i == 2) {
                    type = FITCLOUDMN_QQ;
                }else if (i == 3) {
                    type = FITCLOUDMN_WECHAT;
                }else if (i == 4) {
                    type = FITCLOUDMN_FACEBOOK;
                }else if (i == 5) {
                    type = FITCLOUDMN_TWITTER;
                }else if (i == 6) {
                    type = FITCLOUDMN_LINKEDIN;
                }else if (i == 7) {
                    type = FITCLOUDMN_INSTAGRAM;
                }else if (i == 8) {
                    type = FITCLOUDMN_PINTEREST;
                }else if (i == 9) {
                    type = FITCLOUDMN_WHATSAPP;
                }else if (i == 10) {
                    type = FITCLOUDMN_LINE;
                }else if (i == 11) {
                    type = FITCLOUDMN_MESSENGER;
                }else if (i == 12) {
                    type = FITCLOUDMN_KAKAO;
                }else if (i == 13) {
                    type = FITCLOUDMN_SKYPE;
                }else if (i == 14) {
                    type = FITCLOUDMN_MAIL;
                }else if (i == 15) {
                    type = FITCLOUDMN_OTHER;
                }
                model.value = (mnSetting&type)== type ? @"1" : @"0";
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)switchAction:(UISwitch *)switchs {
    NSInteger index = switchs.tag - 1000;
    FCCommenCellModel *model = self.dataArr[index];
    model.value = switchs.isOn ? @"1" : @"0";

    FITCLOUDMN value = FITCLOUDMN_NONE;
    BOOL select = NO;
    for (FCCommenCellModel *model in self.dataArr) {
        if ([model.value intValue] == 1) {
            select = YES;
            break;
        }
    }
    if (!select) {
        value = FITCLOUDMN_NONE;
    }
    
    int selectCount = 0;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        if ([model.value intValue] == 1) {
            if (i == 0) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_CALL;
                }else {
                    value = value | FITCLOUDMN_CALL;
                }
            }else if (i == 1) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_SMS;
                }else {
                    value = value | FITCLOUDMN_SMS;
                }
            }else if (i == 2) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_QQ;
                }else {
                    value = value | FITCLOUDMN_QQ;
                }
            }else if (i == 3) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_WECHAT;
                }else {
                    value = value | FITCLOUDMN_WECHAT;
                }
            }else if (i == 4) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_FACEBOOK;
                }else {
                    value = value | FITCLOUDMN_FACEBOOK;
                }
            }else if (i == 5) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_TWITTER;
                }else {
                    value = value | FITCLOUDMN_TWITTER;
                }
            }else if (i == 6) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_LINKEDIN;
                }else {
                    value = value | FITCLOUDMN_LINKEDIN;
                }
            }else if (i == 7) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_INSTAGRAM;
                }else {
                    value = value | FITCLOUDMN_INSTAGRAM;
                }
            }else if (i == 8) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_PINTEREST;
                }else {
                    value = value | FITCLOUDMN_PINTEREST;
                }
            }else if (i == 9) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_WHATSAPP;
                }else {
                    value = value | FITCLOUDMN_WHATSAPP;
                }
            }else if (i == 10) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_LINE;
                }else {
                    value = value | FITCLOUDMN_LINE;
                }
            }else if (i == 11) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_MESSENGER;
                }else {
                    value = value | FITCLOUDMN_MESSENGER;
                }
            }else if (i == 12) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_KAKAO;
                }else {
                    value = value | FITCLOUDMN_KAKAO;
                }
            }else if (i == 13) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_SKYPE;
                }else {
                    value = value | FITCLOUDMN_SKYPE;
                }
            }else if (i == 14) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_MAIL;
                }else {
                    value = value | FITCLOUDMN_MAIL;
                }
            }else if (i == 15) {
                if (selectCount == 0) {
                    value = FITCLOUDMN_OTHER;
                }else {
                    value = value | FITCLOUDMN_OTHER;
                }
            }
            
            selectCount += 1;
        }
    }
    
    [FitCloudKit setMessageNotification:value block:^(BOOL succeed, NSError *error) {
        if (succeed) {
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }
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
        NSArray *arr = @[NSLocalizedString(@"Telephony", nil)
                         ,NSLocalizedString(@"SMS", nil),
                         NSLocalizedString(@"QQ", nil),
                         NSLocalizedString(@"WeChat", nil),
                         NSLocalizedString(@"Facebook", nil),
                         NSLocalizedString(@"Twitter", nil),
                         NSLocalizedString(@"LinkedIn", nil),
                         NSLocalizedString(@"Instagram", nil),
                         NSLocalizedString(@"Pinterest", nil),
                         NSLocalizedString(@"WhatsApp", nil),
                         NSLocalizedString(@"Line", nil),
                         NSLocalizedString(@"Facebook Messenger", nil),
                         NSLocalizedString(@"Kakao Talk", nil),
                         NSLocalizedString(@"Skype", nil),
                         NSLocalizedString(@"Email", nil),
                         NSLocalizedString(@"Others App", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}
@end

