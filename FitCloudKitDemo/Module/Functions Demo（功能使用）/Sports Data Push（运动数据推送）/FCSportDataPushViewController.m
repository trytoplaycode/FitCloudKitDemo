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

#pragma mark - Actions
- (void)sureAction {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FitCloudKit enterDFUModeWithBlock:^(BOOL succeed, CBPeripheral *dfuPeripheral, FITCLOUDCHIPVENDOR chipVendor, NSError *error) {
        if (dfuPeripheral) {
            FCDialLibraryModel *model = self.dataArr[self.selectIndexPath.row];
            [FCNetworking downLoadFile:model.binUrl fileName:@"sport.bin" finished:^(NSError * _Nullable error) {
                // download the bin, and send to watch（下载bin文件，并传输给手环，开始进行DFU）
                NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
                NSString *path = [NSString stringWithFormat:@"%@/sport.bin", documentPath];
                BOOL silentMode = FALSE;
                if([FitCloudKit allConfig].firmware.hardwareSupported & FITCLOUDHARDWARE_DFUSHOULDSILENTMODE) {
                    silentMode = TRUE;
                }
                //start DFU（开始进行DFU）
                FITCLOUDDFUCHIPVENDOR chipVendor = FITCLOUDDFUCHIPVENDOR_REALTEK;
                self.dfuSuccess = NO;
                [FitCloudDFUKit startWithPeripheral:dfuPeripheral firmware:path chipVendor:chipVendor silentMode:silentMode];
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                FCDialLibraryModel *model = self.dataArr[self.selectIndexPath.row];
                NSString *name = [model.sportUiName stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *fileName = [NSString stringWithFormat:@"%@.bin", name];
                [FCNetworking downLoadFile:model.binUrl fileName:fileName finished:^(NSError * _Nullable error) {
                    // download the bin, and send to watch（下载bin文件，并传输给手环，开始进行DFU）
                    NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                    NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
                    NSString *path = [NSString stringWithFormat:@"%@/%@", documentPath, fileName];
                    BOOL silentMode = FALSE;
                    if([FitCloudKit allConfig].firmware.hardwareSupported & FITCLOUDHARDWARE_DFUSHOULDSILENTMODE) {
                        silentMode = TRUE;
                    }
                    //star DFU（开始进行DFU）
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
//    NSString *string = [NSString stringWithFormat:@"此次推送%@", self.dfuSuccess ? @"成功" : @"失败"];
    NSString *string = [NSString stringWithFormat:@"Current Push %@", self.dfuSuccess ? @"Success" : @"Failure"];
    NSLog(@"%@", string);
}
#pragma mark - FitCloudDFUDelegate
-(void) OnStartDFUSuccess
{
    NSLog(@"The DFU mode is successfully entered, do not exit the current screen...");
}

-(void) OnStartDFUFailureWithError:(NSError*)error
{
//    NSString *msg = APP_GET_ERROR_MSG(error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"DFU Failure"];
    });
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) OnDFUProgress:(CGFloat)progress imageIndex:(NSInteger)index total:(NSInteger)total
{
    NSLog(@"Current DFU Progress：%2ld%%", (long)roundf(progress));
}

-(void) OnAbortWithError:(NSError*)error
{
//    NSString *msg = APP_GET_ERROR_MSG(error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"On DFU Abort"];
    });
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) OnDFUFinishWithSpeed:(CGFloat)speed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"DFU Success"];
    });
    self.dfuSuccess = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) OnLogMessage:(NSString*)message level:(FCDFUKLogLevel)level
{
    
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

#pragma mark - Lazy
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





