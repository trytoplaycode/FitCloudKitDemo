//
//  FCSportDataPushViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCSportDataPushViewController.h"
#import "FCNetworking.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <FitCloudKit/FitCloudKit.h>
#import <FitCloudDFUKit/FitCloudDFUKit.h>
#import "FCDialLibraryModel.h"
#import "FCSportTypeTableViewCell.h"
#import "FCDefinitions.h"
#import <YYModel/YYModel.h>
#import "FCGlobal.h"

@interface FCSportDataPushViewController ()<UITableViewDelegate, UITableViewDataSource, FitCloudDFUDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, assign) BOOL dfuSuccess;

@end

static NSString *identifier = @"contact";
@implementation FCSportDataPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Sport Data Push", nil)];
    [self initialization];
    [self loadData];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [FitCloudDFUKit setDebugMode:YES];
    [FitCloudDFUKit setDelegate:self];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnReconnectWithDFUMode:) name:FITCLOUDEVENT_PERIPHERAL_RECONNECTEDWITHDFUMODE_NOTIFY object:nil];
}

- (void)loadData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FitCloudAllConfigObject *obj = [FitCloudKit allConfig];
    NSString *hardwareInfo = [obj.firmware.description uppercaseString];
    NSDictionary *params = @{@"hardwareInfo":hardwareInfo};
    [FCNetworking POST:@"public/sportbin/list" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *data = [responseObject objectForKey:@"data"];
            if (data.count > 0) {
                [self.dataArr removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    FCDialLibraryModel *model = [FCDialLibraryModel yy_modelWithJSON:data[i]];
                    model.isSelected = (i == 0);
                    [self.dataArr addObject:model];
                }
                self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark -点击事件
- (void)sureAction {
    // 查询是否可以进行DFU
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FitCloudKit enterDFUModeWithBlock:^(BOOL succeed, CBPeripheral *dfuPeripheral, FITCLOUDCHIPVENDOR chipVendor, NSError *error) {
        if (dfuPeripheral) {
            // DFU存在，获取表盘详情，下载bin文件
            FCDialLibraryModel *model = self.dataArr[self.selectIndexPath.row];
            NSLog(@"开始下载%@的bin文件%@", model.sportUiName, model.binUrl);
            [FCNetworking downLoadFile:model.binUrl fileName:@"sport.bin" finished:^(NSError * _Nullable error) {
                // 下载bin文件，并传输给手环，开始进行DFU
                NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
                NSString *path = [NSString stringWithFormat:@"%@/sport.bin", documentPath];
                BOOL silentMode = FALSE;
                if([FitCloudKit allConfig].firmware.hardwareSupported & FITCLOUDHARDWARE_DFUSHOULDSILENTMODE) {
                    silentMode = TRUE;
                }
                //开始进行DFU
                FITCLOUDDFUCHIPVENDOR chipVendor = FITCLOUDDFUCHIPVENDOR_REALTEK;
                self.dfuSuccess = NO;
                [FitCloudDFUKit startWithPeripheral:dfuPeripheral firmware:path chipVendor:chipVendor silentMode:silentMode];
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                // DFU存在，获取表盘详情，下载bin文件
                FCDialLibraryModel *model = self.dataArr[self.selectIndexPath.row];
                NSLog(@"开始下载%@的bin文件%@", model.sportUiName, model.binUrl);
                NSString *name = [model.sportUiName stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *fileName = [NSString stringWithFormat:@"%@.bin", name];
                [FCNetworking downLoadFile:model.binUrl fileName:fileName finished:^(NSError * _Nullable error) {
                    // 下载bin文件，并传输给手环，开始进行DFU
                    NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                    NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
                    NSString *path = [NSString stringWithFormat:@"%@/%@", documentPath, fileName];
                    BOOL silentMode = FALSE;
                    if([FitCloudKit allConfig].firmware.hardwareSupported & FITCLOUDHARDWARE_DFUSHOULDSILENTMODE) {
                        silentMode = TRUE;
                    }
                    //开始进行DFU
                    FITCLOUDDFUCHIPVENDOR chipVendor = FITCLOUDDFUCHIPVENDOR_REALTEK;
                    self.dfuSuccess = NO;
                    [FitCloudDFUKit startWithPeripheral:[FCGlobal shareInstance].currentPeripheral firmware:path chipVendor:chipVendor silentMode:silentMode];
                }];
            });
        }
    }];
}

-(void)OnReconnectWithDFUMode:(NSNotification*)notification
{
    NSString *string = [NSString stringWithFormat:@"此次推送%@", self.dfuSuccess ? @"成功" : @"失败"];
    NSLog(@"%@", string);
}
#pragma mark - FitCloudDFUDelegate
/**
 * @brief 成功启动DFU回调
 */
-(void) OnStartDFUSuccess
{
    NSLog(@"成功进入DFU模式, 请勿退出当前界面...");
}

/**
 * @brief 启动DFU失败
 * @param error 错误信息
 */
-(void) OnStartDFUFailureWithError:(NSError*)error
{
//    NSString *msg = APP_GET_ERROR_MSG(error);
    NSLog(@"固件升级失败，%@...", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"DFU失败"];
    });
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/**
 * @brief 升级进度回调
 * @param progress 升级进度百分比(0~100)
 * @param index 当前镜像索引，下标从0开始
 * @param total 所有镜像数量
 */
-(void) OnDFUProgress:(CGFloat)progress imageIndex:(NSInteger)index total:(NSInteger)total
{
    NSLog(@"当前固件升级进度：%2ld%%", (long)roundf(progress));
}

/**
 * @brief 意外终止回调
 * @param error 错误信息
 */
-(void) OnAbortWithError:(NSError*)error
{
//    NSString *msg = APP_GET_ERROR_MSG(error);
    NSLog(@"固件升级终止，%@...",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"DFU终止"];
    });
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/**
 * @brief 升级完成回调
 * @param speed 速度
 */
-(void) OnDFUFinishWithSpeed:(CGFloat)speed
{
    NSLog(@"固件升级成功...");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"DFU成功"];
    });
    self.dfuSuccess = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


/**
 *@brief 日志信息回调
 *@param message 日志信息
 *@param level 日志等级
 */
-(void) OnLogMessage:(NSString*)message level:(FCDFUKLogLevel)level
{
    //您可以根据实际需要处理日志逻辑
    
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCSportTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    FCDialLibraryModel *model = self.dataArr[indexPath.row];
    [cell configSport:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndexPath) {
        FCDialLibraryModel *befor = self.dataArr[self.selectIndexPath.row];
        befor.isSelected = NO;
    }
    FCDialLibraryModel *model = self.dataArr[indexPath.row];
    model.isSelected = YES;
    
    [self.tableView reloadData];
    self.selectIndexPath = indexPath;
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-100)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        [_tableView registerClass:[FCSportTypeTableViewCell class] forCellReuseIdentifier:identifier];
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
        [_sureButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}
@end





