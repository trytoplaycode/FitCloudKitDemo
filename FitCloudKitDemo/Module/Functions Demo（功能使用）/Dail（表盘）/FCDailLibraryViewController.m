//
//  FCDailLibraryViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCDailLibraryViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCDailLibraryCollectionViewCell.h"
#import <SDWebImage.h>
#import <FitCloudKit/FitCloudKit.h>
#import <FitCloudDFUKit/FitCloudDFUKit.h>

#import "FCNetworking.h"
#import "FCDialLibraryModel.h"
#import <YYModel.h>
#import <MBProgressHUD.h>
#import "FCGlobal.h"
#import <Toast.h>
@interface FCDailLibraryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, FitCloudDFUDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, assign) BOOL dfuSuccess;

@end

static NSString *identifier = @"dail";

@implementation FCDailLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"DIAL LIBRARY", nil)];
    [self initialization];
    [self loadData];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [FitCloudDFUKit setDebugMode:YES];
    [FitCloudDFUKit setDelegate:self];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.sureButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnReconnectWithDFUMode:) name:FITCLOUDEVENT_PERIPHERAL_RECONNECTEDWITHDFUMODE_NOTIFY object:nil];
}

-(void)OnReconnectWithDFUMode:(NSNotification*)notification
{
    NSString *string = [NSString stringWithFormat:@"Current Push %@", self.dfuSuccess ? @"Success" : @"Failure"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:string];
    });
}

- (void)loadData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FitCloudKit getWatchfaceUIInformationWithBlock:^(BOOL succeed, FitCloudWatchfaceUIInfo *faceUI, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (faceUI) {
                FitCloudAllConfigObject *obj = [FitCloudKit allConfig];
                NSString *hardwareInfo = [obj.firmware.description uppercaseString];
                NSDictionary *params = @{@"hardwareInfo":hardwareInfo,
                                         @"lcd":@(faceUI.lcd),
                                         @"toolVersion":faceUI.toolVersion
                };
                // get the online dial list(获取表盘列表)
                [FCNetworking POST:@"public/dial/list" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *data = [responseObject objectForKey:@"data"];
                        if (data.count > 0) {
                            [self.dataArr removeAllObjects];
                            for (NSInteger i = 0; i < data.count; i++) {
                                FCDialLibraryModel *model = [FCDialLibraryModel yy_modelWithJSON:data[i]];
                                [self.dataArr addObject:model];
                            }
                            [self.collectionView reloadData];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    });
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

                }];
            }
        });
    }];
}

- (void)sureAction {
    if (!self.selectIndexPath) {
        [self.view makeToast:NSLocalizedString(@"Please choose the dial", nil)];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FitCloudKit enterDFUModeWithBlock:^(BOOL succeed, CBPeripheral *dfuPeripheral, FITCLOUDCHIPVENDOR chipVendor, NSError *error) {
        if (dfuPeripheral) {
            ///public/sportbin/list
            FCDialLibraryModel *model = self.dataArr[self.selectIndexPath.row];
            [FCNetworking POST:@"public/dial/get" parameters:@{@"data":[NSString stringWithFormat:@"[%@]", @(model.dialNum)]} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self parserReult:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.description];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }];
}

- (void)parserReult:(id)result {
    NSDictionary *data = [[result objectForKey:@"data"] firstObject];
    NSString *binUrl = [data objectForKey:@"binUrl"];
    [FCNetworking downLoadFile:binUrl fileName:@"dail.bin" finished:^(NSError * _Nullable error) {
        if (!error) {
            // download the bin, and send to watch（下载bin文件，并传输给手环，开始进行DFU）
            NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
            NSString *path = [NSString stringWithFormat:@"%@/dail.bin", documentPath];
            BOOL silentMode = FALSE;
            if([FitCloudKit allConfig].firmware.hardwareSupported & FITCLOUDHARDWARE_DFUSHOULDSILENTMODE) {
                silentMode = TRUE;
            }
            //start DFU
            self.dfuSuccess = NO;
            FITCLOUDDFUCHIPVENDOR chipVendor = FITCLOUDDFUCHIPVENDOR_REALTEK;
            [FitCloudDFUKit startWithPeripheral:[FCGlobal shareInstance].currentPeripheral firmware:path chipVendor:chipVendor silentMode:silentMode];
        }
    }];
}
#pragma mark - FitCloudDFUDelegate
-(void) OnStartDFUSuccess
{
    NSLog(@"The DFU mode is successfully entered, do not exit the current screen...");
}

-(void) OnStartDFUFailureWithError:(NSError*)error
{
    NSLog(@"DFU failure，%@...", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [FitCloudKit exitDFUModeWithBlock:^(BOOL succeed, NSError *error) {
            [FitCloudKit connect:[FCGlobal shareInstance].currentPeripheral];
        }];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view makeToast:@"DFU Failure"];
    });
}

-(void) OnDFUProgress:(CGFloat)progress imageIndex:(NSInteger)index total:(NSInteger)total
{
    NSLog(@"Current DFU Progress：%2ld%%", (long)roundf(progress));
}

-(void) OnAbortWithError:(NSError*)error
{
//    NSString *msg = APP_GET_ERROR_MSG(error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [FitCloudKit exitDFUModeWithBlock:^(BOOL succeed, NSError *error) {
            [FitCloudKit connect:[FCGlobal shareInstance].currentPeripheral];
        }];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view makeToast:@"on DFU Abort"];
    });
}

-(void) OnDFUFinishWithSpeed:(CGFloat)speed
{
    self.dfuSuccess = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [FitCloudKit exitDFUModeWithBlock:^(BOOL succeed, NSError *error) {
            [FitCloudKit connect:[FCGlobal shareInstance].currentPeripheral];
        }];
        NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
        NSString *path = [NSString stringWithFormat:@"%@/dail.bin", documentPath];
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view makeToast:NSLocalizedString(@"Push Success", nil)];
    });
}

-(void) OnLogMessage:(NSString*)message level:(FCDFUKLogLevel)level
{
    
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCDailLibraryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    FCDialLibraryModel *model = self.dataArr[indexPath.row];
    [cell configDailLibrary:model];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndexPath) {
        FCDialLibraryModel *befor = self.dataArr[self.selectIndexPath.row];
        befor.isSelected = NO;
    }
    FCDialLibraryModel *model = self.dataArr[indexPath.row];
    model.isSelected = !model.isSelected;
    
    [self.collectionView reloadData];
    self.selectIndexPath = indexPath;
}

#pragma mark - Lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((kScreenWidth-20)/3.f, (kScreenWidth-20)/3.f);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-100) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FCDailLibraryCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    
    return _collectionView;
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
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.collectionView.frame)+20, kScreenWidth-100, 50);
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
