//
//  FCDailCustomViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCDailCustomViewController.h"
#import "FCNetworking.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import <FitCloudKit/FitCloudKit.h>
#import <FitCloudDFUKit/FitCloudDFUKit.h>
#import <FitCloudWFKit/FitCloudWFKit.h>

#import "FCDefinitions.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import <YYModel/YYModel.h>
#import "FCDailLibraryCollectionViewCell.h"
#import "FCCommenCellModel.h"
#import <SDWebImage.h>
#import <Masonry.h>
#import "FCGlobal.h"
#import "LocalizedButton.h"

@interface FCDailCustomViewController ()<TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, FitCloudDFUDelegate>

@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *BottomButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightPButton;

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) UIImageView *styleImageView;
@property (nonatomic, strong) UIImage *selectBgImage;

@property (weak, nonatomic) IBOutlet UIImageView *topImgView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImgView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImgView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) NSString *binUrl;
@property (nonatomic, assign) FITCLOUDWATCHFACEDTPOSITION position;
@property (nonatomic, copy) NSString *resultBinPath;
@property (weak, nonatomic) IBOutlet LocalizedButton *sureButton;
@property (assign, nonatomic) BOOL dfuSuccess;

@end

static NSString *identifier = @"custom";
@implementation FCDailCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"DIAL CUSTOM", nil)];
    [self initialization];
    [self loadData];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [FitCloudDFUKit setDebugMode:YES];
    [FitCloudDFUKit setDelegate:self];
    
    [self.sureButton setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
    self.position = FITCLOUDWATCHFACEDTPOSITION_TOP;
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(70);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.size.mas_equalTo(CGSizeMake(220, 220));
    }];
    self.previewImageView.backgroundColor = [UIColor blackColor];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.previewImageView.clipsToBounds = YES;
    self.previewImageView.layer.cornerRadius = 110;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 20;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[FCDailLibraryCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    [self.previewImageView addSubview:self.styleImageView];
    [self.styleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.previewImageView.mas_centerX).offset(0);
        make.top.mas_equalTo(self.previewImageView.mas_top).offset(10);
    }];
}

- (void)loadData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FitCloudKit getWatchfaceUIInformationWithBlock:^(BOOL succeed, FitCloudWatchfaceUIInfo *faceUI, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *params = @{@"lcd":@(faceUI.lcd),
                                     @"toolVersion":faceUI.toolVersion
            };
            weakSelf(weakSelf);
            [FCNetworking POST:@"public/dial/customgui" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.dataArr removeAllObjects];
                    NSArray *arr = [responseObject objectForKey:@"data"];
                    NSDictionary *info = [arr firstObject];
                    weakSelf.binUrl = [info objectForKey:@"binUrl"];
                    NSArray *components = [info objectForKey:@"components"];
                    if ([components isKindOfClass:[NSArray class]]) {
                        NSDictionary *component = [components firstObject];
                        NSArray *urls = [component objectForKey:@"urls"];
                        NSLog(@"%@", urls);
                        if ([urls isKindOfClass:[NSArray class]]) {
                            for (NSInteger i = 0; i < urls.count; i++) {
                                FCCommenCellModel *model = [FCCommenCellModel new];
                                model.value = urls[i];
                                if (i == 0) {
                                    [weakSelf.styleImageView sd_setImageWithURL:[NSURL URLWithString:urls[i]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf.styleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                                                make.centerX.mas_equalTo(weakSelf.previewImageView.mas_centerX).offset(0);
                                                make.top.mas_equalTo(weakSelf.previewImageView.mas_top).offset(10);
                                                make.size.mas_equalTo(CGSizeMake(image.size.width/2.f, image.size.height/2.f));
                                            }];
                                        });
                                    }];
                                    weakSelf.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                }
                                model.isSelected = (i == 0);
                                [weakSelf.dataArr addObject:model];
                            }
                        }
                    }

                    [weakSelf.collectionView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                NSLog(@"123");
            }];
        });
    }];
}

- (UIImage *)snapshotWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
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
        [self.sureButton setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.dfuSuccess = YES;
    });
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


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCDailLibraryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell configDail:self.dataArr[indexPath.item]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndexPath) {
        FCCommenCellModel *befor = self.dataArr[self.selectIndexPath.row];
        befor.isSelected = NO;
    }
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    model.isSelected = !model.isSelected;
    weakSelf(weakSelf);
    [self.styleImageView sd_setImageWithURL:[NSURL URLWithString:model.value?:@""] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.styleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(image.size.width/2.f, image.size.height/2.f));
            }];
        });
    }];
    [self.collectionView reloadData];
    self.selectIndexPath = indexPath;
}

#pragma mark - 点击事件
- (IBAction)selectAction:(id)sender {
    weakSelf(weakSelf);
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        weakSelf.selectBgImage = [photos firstObject];
        weakSelf.previewImageView.image = [photos firstObject];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (IBAction)topAction:(id)sender {
    self.position = FITCLOUDWATCHFACEDTPOSITION_TOP;
    self.bottomImgView.image = IMAGENAME(@"unselected");
    self.leftImgView.image = IMAGENAME(@"unselected");
    self.rightImgView.image = IMAGENAME(@"unselected");
    self.topImgView.image = IMAGENAME(@"selected");
    [self.styleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.previewImageView.mas_centerX).offset(0);
        make.top.mas_equalTo(self.previewImageView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(self.styleImageView.image.size.width/2.f, self.styleImageView.image.size.height/2.f));
    }];
}

- (IBAction)bottomAction:(id)sender {
    self.position = FITCLOUDWATCHFACEDTPOSITION_BOTTOM;
    self.bottomImgView.image = IMAGENAME(@"selected");
    self.leftImgView.image = IMAGENAME(@"unselected");
    self.rightImgView.image = IMAGENAME(@"unelected");
    self.topImgView.image = IMAGENAME(@"unselected");
    [self.styleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.previewImageView.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.previewImageView.mas_bottom).offset(-10);
        make.size.mas_equalTo(CGSizeMake(self.styleImageView.image.size.width/2.f, self.styleImageView.image.size.height/2.f));
    }];
}

- (IBAction)leftAction:(id)sender {
    self.position = FITCLOUDWATCHFACEDTPOSITION_LEFT;
    self.bottomImgView.image = IMAGENAME(@"unselected");
    self.leftImgView.image = IMAGENAME(@"selected");
    self.rightImgView.image = IMAGENAME(@"unselected");
    self.topImgView.image = IMAGENAME(@"unselected");
    [self.styleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.previewImageView.mas_centerY).offset(0);
        make.left.mas_equalTo(self.previewImageView.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(self.styleImageView.image.size.width/2.f, self.styleImageView.image.size.height/2.f));
    }];
}

- (IBAction)rightAction:(id)sender {
    self.position = FITCLOUDWATCHFACEDTPOSITION_RIGHT;
    
    self.bottomImgView.image = IMAGENAME(@"unselected");
    self.leftImgView.image = IMAGENAME(@"unselected");
    self.rightImgView.image = IMAGENAME(@"selected");
    self.topImgView.image = IMAGENAME(@"unselected");
    [self.styleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.previewImageView.mas_centerY).offset(0);
        make.right.mas_equalTo(self.previewImageView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(self.styleImageView.image.size.width/2.f, self.styleImageView.image.size.height/2.f));
    }];
}

- (IBAction)createAction:(id)sender {
    if ([self.sureButton.titleLabel.text isEqualToString:NSLocalizedString(@"Push", nil)]) {
        // 推送至手环
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        BOOL silentMode = FALSE;
        if([FitCloudKit allConfig].firmware.hardwareSupported & FITCLOUDHARDWARE_DFUSHOULDSILENTMODE) {
            silentMode = TRUE;
        }
        //开始进行DFU
        FITCLOUDDFUCHIPVENDOR chipVendor = FITCLOUDDFUCHIPVENDOR_REALTEK;
        self.dfuSuccess = NO;
        [FitCloudDFUKit startWithPeripheral:[FCGlobal shareInstance].currentPeripheral firmware:self.resultBinPath chipVendor:chipVendor silentMode:silentMode];
    }else {
        // 创建自定义表盘
        if (!self.selectBgImage) {
            NSLog(@"please select backgroud image");
            return;
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [FCNetworking downLoadFile:self.binUrl?:@"" fileName:@"customDial.bin" finished:^(NSError * _Nullable error) {
            [self createCustomDial];
        }];
    }
}

- (void)createCustomDial {
    weakSelf(weakSelf);
    FitCloudAllConfigObject *allConfig = [FitCloudKit allConfig];

    BOOL isNextGUI = [allConfig isKindOfClass:[FitCloudAllConfigObject class]] && allConfig.firmware && allConfig.firmware.isNewGUIArchitecture;

    NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/customDial.bin", documentPath];
    
    [FitCloudWFKit createWithTemplateBin:path isNextGUI:isNextGUI rewriteNextGUIWatchfaceNo:nil bkImage:self.selectBgImage bkCornerRadius:0 preview:[self snapshotWithView:self.previewImageView] dtPosition:self.position progress:^(CGFloat progress, NSString * _Nullable message) {
        
    } logging:^(FCWKLOGLEVEL level, NSString * _Nullable message) {
        message = [[message stringByReplacingOccurrencesOfString:@"<" withString:@"["] stringByReplacingOccurrencesOfString:@">" withString:@"]"];
        if(level == FCWKLOGLEVEL_INFO)
        {
            NSLog(@"%@", message);
        }
        else if(level == FCWKLOGLEVEL_WARNING)
        {
            NSLog(@"%@", message);
        }
        else if(level == FCWKLOGLEVEL_ERROR)
        {
            NSLog(@"%@", message);
        }
    } completion:^(BOOL success, NSString * _Nullable resultBinPath, UIImage * _Nullable resultBkImage, UIImage * _Nullable resultPreview, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.resultBinPath = resultBinPath;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if(success)
            {
                [weakSelf.sureButton setTitle:NSLocalizedString(@"Push", nil) forState:UIControlStateNormal];
                [weakSelf.view makeToast:@"制作成功"];
                NSLog(@"create watchface success, bin file: %@", resultBinPath);
            }
            else
            {
                [self.view makeToast:@"制作失败"];
                NSLog(@"create watchface failure with error: %@", error.localizedDescription);
            }
        });
    }];
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
    }
    
    return _dataArr;
}

- (UIImageView *)styleImageView {
    if (!_styleImageView) {
        _styleImageView = [UIImageView new];
        _styleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _styleImageView;
}

@end
