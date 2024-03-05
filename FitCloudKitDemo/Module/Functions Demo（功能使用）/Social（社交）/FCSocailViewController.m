//
//  FCSocailViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/28.
//

#import "FCSocailViewController.h"
#import "FCDefinitions.h"
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import "FCGlobal.h"
@interface FCSocailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;

@end

static NSString *identifier = @"social";
@implementation FCSocailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Social Contact", nil)];
    [self initialization];
    [self loadScreenDisplay];
}

- (void)loadScreenDisplay {

}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
}

- (void)sureAction {
    if (![FitCloudKit deviceReady]) {
        [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
        return;
    }
    
    NSInteger index = 0;
    FITCLOUDQRCODE value = 0;
    BOOL select = NO;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        if ([model.value intValue] == 1) {
            select = YES;
            index = i;
            break;
        }
    }

    if (!select) {
        [self.view makeToast:NSLocalizedString(@"Please choose the application", nil)];
        return;
    }
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        if ([model.value isEqualToString:@"1"]) {
            FITCLOUDQRCODE current = 0;
            if (i == 0) {
                current = FITCLOUDQRCODE_BUSINESSCARD_WECHAT;
            }else if (i == 1) {
                current = FITCLOUDQRCODE_BUSINESSCARD_ALIPAY;
            }else if (i == 2) {
                current = FITCLOUDQRCODE_BUSINESSCARD_QQ;
            }else if (i == 3) {
                current = FITCLOUDQRCODE_BUSINESSCARD_FACEBOOK;
            }else if (i == 4) {
                current = FITCLOUDQRCODE_BUSINESSCARD_WHATSAPP;
            }else if (i == 5) {
                current = FITCLOUDQRCODE_BUSINESSCARD_MESSENGER;
            }else if (i == 6) {
                current = FITCLOUDQRCODE_BUSINESSCARD_LINE;
            }else if (i == 7) {
                current = FITCLOUDQRCODE_BUSINESSCARD_SNAPCHAT;
            }else if (i == 8) {
                current = FITCLOUDQRCODE_BUSINESSCARD_SKYPE;
            }else if (i == 9) {
                current = FITCLOUDQRCODE_BUSINESSCARD_EMAIL;
            }else if (i == 10) {
                current = FITCLOUDQRCODE_BUSINESSCARD_PHONE;
            }else if (i == 11) {
                current = FITCLOUDQRCODE_BUSINESSCARD_LINKEDIN;
            }
            value = current;
        }
    }
    if (value == 0) {return;}
    [FitCloudKit sendQRCode:value content:@"www.baidu.com" withBlock:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
            [[NSUserDefaults standardUserDefaults] setObject:@(index) forKey:kSocial];
        });
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleSelect];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.selectImageView.image = [model.value intValue] == 0 ? IMAGENAME(@"unselected") : IMAGENAME(@"selected");

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (FCCommenCellModel *m in self.dataArr) {
        m.value = @"0";
    }
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    model.value = [model.value intValue] == 0 ? @"1" : @"0";
    [self.tableView reloadData];
}
#pragma mark - Lazy
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
        NSArray *arr = @[NSLocalizedString(@"WeChat", nil),NSLocalizedString(@"Alipay", nil),NSLocalizedString(@"QQ", nil),NSLocalizedString(@"Facebook", nil),NSLocalizedString(@"WhatsApp", nil),NSLocalizedString(@"Facebook Messenger", nil),NSLocalizedString(@"Line", nil),NSLocalizedString(@"Snapchat", nil),NSLocalizedString(@"Skype", nil),NSLocalizedString(@"Email", nil),NSLocalizedString(@"Phone", nil),NSLocalizedString(@"LinkedIn", nil)];
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:kSocial] intValue];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            if (i == index) {
                model.value = @"1";
            }
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth-100, 50);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:NSLocalizedString(@"Set", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}
@end


