//
//  FCFuncListViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCFuncListViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import <FitCloudKit/FitCloudKit.h>
#import "FCFuncListTableViewCell.h"
#import "FCStepViewController.h"
#import "FCAboutBraceletViewController.h"
#import "FCDeviceConfigViewController.h"
#import "FCAlarmListViewController.h"
#import "FCWeatherViewController.h"
#import "FCWomenHealthyViewController.h"
#import "FCScreenDisplayViewController.h"
#import "FCQRCodeViewController.h"
#import "FCSocailViewController.h"
#import <MBProgressHUD.h>
#import <YYModel.h>
#import "FCCommenRecordModel.h"
#import "FCHisoryListViewController.h"
#import "FCWatchStyleViewController.h"
#import "FCContactViewController.h"
#import "FCNetworking.h"
#import "FCWatchFaceViewController.h"
#import "FCSportDataPushViewController.h"
#import "FCGlobal.h"
#import "FCSearchViewController.h"
#import "FCDeviceBindViewController.h"
@interface FCFuncListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

static NSString *identifier = @"list";

@implementation FCFuncListViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled  = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled  = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Demos", nil)];
    [self setNavBackWhite];
    [self initialization];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.label.text = NSLocalizedString(@"Synchronous", nil);
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
}

- (void)backAction {
    UIViewController *viewcontroller = nil;
    for (NSInteger i = 0; i < self.navigationController.viewControllers.count; i++) {
        UIViewController *viewController = self.navigationController.viewControllers[i];
        if ([viewController isKindOfClass:[FCSearchViewController class]]) {
            viewcontroller = viewController;
            break;
        }
    }
    
    if ([FitCloudKit deviceReady]) {
        if (viewcontroller) {
            [self.navigationController popToViewController:viewcontroller animated:YES];
        }else {
            FCSearchViewController *detail = [FCSearchViewController new];
            [self.navigationController pushViewController:detail animated:YES];
        }
    }else {
        FCSearchViewController *search = [FCSearchViewController new];
        search.step = 0;
        [self.navigationController pushViewController:search animated:YES];
    }
}

- (NSMutableArray *)dealWithTotal:(NSMutableArray *)total {
    [total sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        FCCommenRecordModel *model = [FCCommenRecordModel yy_modelWithJSON:obj1];
        FCCommenRecordModel *historyModel = [FCCommenRecordModel yy_modelWithJSON:obj2];
        NSString *dateString = model.recordDate;
        NSString *historyDateString = historyModel.recordDate;
        NSDate *date = [self.formatter dateFromString:dateString];
        NSDate *historyDate = [self.formatter dateFromString:historyDateString];
        if ([date compare:historyDate] == NSOrderedAscending) {
            return NSOrderedDescending;
        }else if ([date compare:historyDate] == NSOrderedSame) {
            return NSOrderedSame;
        }else {
            return NSOrderedAscending;
        }
    }];
    for (NSInteger i = total.count-1; i >= 0; i--) {
        FCCommenRecordModel *model = [FCCommenRecordModel yy_modelWithJSON:total[i]];
        BOOL exist = NO;
        // Filter the data whose value is 0（过滤值为0的数据）
        int value = 0;
        if (model.type == FCHistoryTypeStep) {
            value = model.steps;
        }else if (model.type == FCHistoryTypeSleep) {
            value = 1;
        }else if (model.type == FCHistoryTypeSports) {
            value = model.duration;
        }else if (model.type == FCHistoryTypeHeartRate) {
            value = model.hrValue;
        }else if (model.type == FCHistoryTypeBloodOxygen) {
            value = model.boValue;
        }else if (model.type == FCHistoryTypeBloodPressure) {
            value = model.diastolic;
        }
        if (value == 0) {
            [total removeObjectAtIndex:i];
            continue;
        }
        //Merge data with the same date（合并日期相同的数据）
        for (NSInteger j = i-1; j >= 0; j--) {
            FCCommenRecordModel *historyModel = [FCCommenRecordModel yy_modelWithJSON:total[j]];
            if ([model.recordDate isEqualToString:historyModel.recordDate]) {
                if (model.type == FCHistoryTypeStep) {
                    historyModel.steps = MAX(model.steps, historyModel.steps);
                    historyModel.distance = MAX(model.distance, historyModel.distance);
                    historyModel.calory = MAX(model.calory, historyModel.calory);
                }else if (model.type == FCHistoryTypeSleep) {
                    historyModel.quality = MAX(model.quality, historyModel.quality);
                }else if (model.type == FCHistoryTypeSports) {
                    historyModel.genre = MAX(model.genre, historyModel.genre);
                    historyModel.duration = MAX(model.duration, historyModel.duration);
                    historyModel.steps = MAX(model.steps, historyModel.steps);
                    historyModel.distance = MAX(model.distance, historyModel.distance);
                    historyModel.calory = MAX(model.calory, historyModel.calory);
                    historyModel.pace = MAX(model.hr_excercise, historyModel.hr_excercise);
                }else if (model.type == FCHistoryTypeHeartRate) {
                    historyModel.hrValue = MAX(model.hrValue, historyModel.hrValue);
                }else if (model.type == FCHistoryTypeBloodOxygen) {
                    historyModel.boValue = MAX(model.boValue, historyModel.boValue);
                }else if (model.type == FCHistoryTypeBloodPressure) {
                    historyModel.diastolic = MAX(model.diastolic, historyModel.diastolic);
                    historyModel.systolic = MAX(model.systolic, historyModel.systolic);
                }
                exist = YES;
            }
        }
        if (exist) {
            [total removeObjectAtIndex:i];
        }
    }
    
    return total;
}

- (void)sureAction {
    if (![FitCloudKit deviceReady]) {
        [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
        return;
    }
    weakSelf(weakSelf);
    [self.hud showAnimated:YES];
    [FitCloudKit manualSyncDataWithOption:FITCLOUDDATASYNCOPTION_ALL progress:^(CGFloat progress, NSString *tip) {
        
    } block:^(BOOL succeed, NSString *userId, NSArray<FitCloudManualSyncRecordObject *> *records, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *stepRcords = @[].mutableCopy;
            NSMutableArray *bpRcords = @[].mutableCopy;
            NSMutableArray *hrRcords = @[].mutableCopy;
            NSMutableArray *boRcords = @[].mutableCopy;
            NSMutableArray *tmRcords = @[].mutableCopy;
            NSMutableArray *sleepRcords = @[].mutableCopy;
            NSMutableArray *sprotsRcords = @[].mutableCopy;

            for (NSInteger i = 0; i < records.count; i++) {
                FitCloudManualSyncRecordObject *obj = records[i];
                if ([obj isKindOfClass:[FitCloudBORecordObject class]]) {
                    // Blood oxygen（血氧）
                    FitCloudBORecordObject *step = (FitCloudBORecordObject *)obj;
                    for (NSInteger index = 0; index < step.items.count; index++) {
                        FitCloudBOItemObject *item = step.items[index];
                        FCCommenRecordModel *commen = [FCCommenRecordModel new];
                        commen.type = FCHistoryTypeBloodOxygen;
                        commen.recordDate = [weakSelf.formatter stringFromDate:item.moment];
                        commen.boValue = item.value;
                        [boRcords addObject:[commen yy_modelToJSONString]];
                    }
                }else if ([obj isKindOfClass:[FitCloudBPRecordObject class]]) {
                    // Blood pressure （血压）
                    FitCloudBPRecordObject *step = (FitCloudBPRecordObject *)obj;
                    for (NSInteger index = 0; index < step.items.count; index++) {
                        FitCloudBPItemObject *item = step.items[index];
                        FCCommenRecordModel *commen = [FCCommenRecordModel new];
                        commen.type = FCHistoryTypeBloodOxygen;
                        commen.recordDate = [weakSelf.formatter stringFromDate:item.moment];
                        commen.diastolic = item.diastolic;
                        commen.systolic = item.systolic;
                        [bpRcords addObject:[commen yy_modelToJSONString]];
                    }
                }else if ([obj isKindOfClass:[FitCloudHRRecordObject class]]) {
                    // Heart rate（心率）
                    FitCloudHRRecordObject *step = (FitCloudHRRecordObject *)obj;
                    for (NSInteger index = 0; index < step.items.count; index++) {
                        FitCloudHRItemObject *item = step.items[index];
                        FCCommenRecordModel *commen = [FCCommenRecordModel new];
                        commen.type = FCHistoryTypeHeartRate;
                        commen.recordDate = [weakSelf.formatter stringFromDate:item.moment];
                        commen.hrValue = item.value;
                        [hrRcords addObject:[commen yy_modelToJSONString]];
                    }
                }else if ([obj isKindOfClass:[FitCloudSleepRecordObject class]]) {
                    // Sleep（睡眠）
                    FitCloudSleepRecordObject *step = (FitCloudSleepRecordObject *)obj;
                    for (NSInteger index = 0; index < step.items.count; index++) {
                        FitCloudSleepItemObject *item = step.items[index];
                        FCCommenRecordModel *commen = [FCCommenRecordModel new];
                        commen.type = FCHistoryTypeSleep;
                        commen.recordDate = [weakSelf.formatter stringFromDate:item.moment];
                        commen.quality = item.quality;
                        [sleepRcords addObject:[commen yy_modelToJSONString]];
                    }
                }else if ([obj isKindOfClass:[FitCloudSportsRecordObject class]]) {
                    // Sports Data（运动数据）
                    FitCloudSportsRecordObject *step = (FitCloudSportsRecordObject *)obj;
                    for (NSInteger index = 0; index < step.items.count; index++) {
                        FitCloudSportsItemObject *item = step.items[index];
                        FCCommenRecordModel *commen = [FCCommenRecordModel new];
                        commen.type = FCHistoryTypeSports;
                        commen.recordDate = [weakSelf.formatter stringFromDate:item.moment];
                        commen.genre = item.genre;
                        commen.duration = item.duration;
                        commen.steps = item.steps;
                        commen.distance = item.distance;
                        commen.calory = item.calory;
                        commen.pace = item.hr_excercise;
                        [sprotsRcords addObject:[commen yy_modelToJSONString]];
                    }
                }else if ([obj isKindOfClass:[FitCloudStepRecordObject class]]) {
                    // Step（步数）
                    FitCloudStepRecordObject *step = (FitCloudStepRecordObject *)obj;
                    for (NSInteger index = 0; index < step.items.count; index++) {
                        FitCloudStepItemObject *item = step.items[index];
                        FCCommenRecordModel *commen = [FCCommenRecordModel new];
                        commen.type = FCHistoryTypeStep;
                        commen.recordDate = [weakSelf.formatter stringFromDate:item.moment];
                        commen.steps = item.steps;
                        commen.distance = item.distance;
                        commen.calory = item.calory;
                        [stepRcords addObject:[commen yy_modelToJSONString]];
                    }
                }
            }
            /// 注意：正规使用场景建议使用数据库进行存储管理，此处仅为演示
            /// notice：Normal application scenario You are advised to use a database for storage management, This is for demonstration purposes only
            // Step（步数）
            NSArray *steps = [[NSUserDefaults standardUserDefaults] objectForKey:kStepRecordList];
            NSMutableArray *totalSteps = steps ? steps.mutableCopy : @[].mutableCopy;
            [totalSteps addObjectsFromArray:stepRcords];
            totalSteps = [self dealWithTotal:totalSteps];
            [[NSUserDefaults standardUserDefaults] setObject:totalSteps forKey:kStepRecordList];
            
            // Blood oxygen（血氧）
            NSArray *bo = [[NSUserDefaults standardUserDefaults] objectForKey:kBORecordList];
            NSMutableArray *totalBo = bo ? bo.mutableCopy : @[].mutableCopy;
            [totalBo addObjectsFromArray:boRcords];
            totalBo = [self dealWithTotal:totalBo];
            [[NSUserDefaults standardUserDefaults] setObject:totalBo forKey:kBORecordList];
            
            // Heart rate（心率）
            NSArray *hr = [[NSUserDefaults standardUserDefaults] objectForKey:kHRRecordList];
            NSMutableArray *totalHR = hr ? hr.mutableCopy : @[].mutableCopy;
            [totalHR addObjectsFromArray:hrRcords];
            totalHR = [self dealWithTotal:totalHR];
            [[NSUserDefaults standardUserDefaults] setObject:totalHR forKey:kHRRecordList];
            
            // Blood pressure （血压）
            NSArray *bp = [[NSUserDefaults standardUserDefaults] objectForKey:kHRRecordList];
            NSMutableArray *totalBP = bp ? bp.mutableCopy : @[].mutableCopy;
            [totalBP addObjectsFromArray:bpRcords];
            totalBP = [self dealWithTotal:totalBP];
            [[NSUserDefaults standardUserDefaults] setObject:totalBP forKey:kBPRecordList];
            
            //Body temperature（体温）
            NSArray *tm = [[NSUserDefaults standardUserDefaults] objectForKey:kBTRecordList];
            NSMutableArray *totalTM = tm ? tm.mutableCopy : @[].mutableCopy;
            [totalTM addObjectsFromArray:tmRcords];
            totalTM = [self dealWithTotal:totalTM];
            [[NSUserDefaults standardUserDefaults] setObject:totalTM forKey:kBTRecordList];
            
            //Sleep（睡眠）
            NSArray *sleep = [[NSUserDefaults standardUserDefaults] objectForKey:kSleepRecordList];
            NSMutableArray *totalSleep = sleep ? sleep.mutableCopy : @[].mutableCopy;
            [totalSleep addObjectsFromArray:sleepRcords];
            totalSleep = [self dealWithTotal:totalSleep];
            [[NSUserDefaults standardUserDefaults] setObject:totalSleep forKey:kSleepRecordList];
            
            [self.hud hideAnimated:YES];
//            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
    }];
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
    switch (indexPath.row) {
        case 0:
        {
            FCStepViewController *step = [FCStepViewController new];
            [self.navigationController pushViewController:step animated:YES];
        }
            break;
        case 1:
        {
            FCDeviceConfigViewController *config = [FCDeviceConfigViewController new];
            [self.navigationController pushViewController:config animated:YES];
        }
            break;
        case 2:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCAlarmListViewController *alarm = [FCAlarmListViewController new];
            [self.navigationController pushViewController:alarm animated:YES];
        }
            break;
        case 3:
        {
            FCWeatherViewController *weahther = [FCWeatherViewController new];
            [self.navigationController pushViewController:weahther animated:YES];
        }
            break;
        case 4:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCWomenHealthyViewController *women = [FCWomenHealthyViewController new];
            [self.navigationController pushViewController:women animated:YES];
        }
            break;
        case 5:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCScreenDisplayViewController *display = [FCScreenDisplayViewController new];
            [self.navigationController pushViewController:display animated:YES];
        }
            break;
        case 6:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCWatchStyleViewController *display = [FCWatchStyleViewController new];
            [self.navigationController pushViewController:display animated:YES];
        }
            break;
        case 7:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCWatchFaceViewController *face = [FCWatchFaceViewController new];
            [self.navigationController pushViewController:face animated:YES];
        }
            break;
        case 8:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCSportDataPushViewController *sport = [FCSportDataPushViewController new];
            [self.navigationController pushViewController:sport animated:YES];
        }
            break;
        case 9:
        {
            FCQRCodeViewController *code = [FCQRCodeViewController new];
            [self.navigationController pushViewController:code animated:YES];
        }
            break;
        case 10:
        {
            FCSocailViewController *socail = [FCSocailViewController new];
            [self.navigationController pushViewController:socail animated:YES];
        }
            break;
        case 11:
        {
            FCHisoryListViewController *hisoty = [FCHisoryListViewController new];
            [self.navigationController pushViewController:hisoty animated:YES];
        }
            break;
        case 12:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCContactViewController *contact = [FCContactViewController new];
            [self.navigationController pushViewController:contact animated:YES];
        }
            break;
        case 13:
        {
            if (![FitCloudKit deviceReady]) {
                [self.view makeToast:NSLocalizedString(@"Please connect the bracelet first", nil) duration:1.f position:CSToastPositionTop];
                return;
            }
            FCAboutBraceletViewController *abount = [FCAboutBraceletViewController new];
            [self.navigationController pushViewController:abount animated:YES];
        }
            break;
        default:
            break;
    }
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
        [_dataArr addObject:NSLocalizedString(@"Step", nil)];
        [_dataArr addObject:NSLocalizedString(@"Device Config", nil)];
        [_dataArr addObject:NSLocalizedString(@"Alarm", nil)];
        [_dataArr addObject:NSLocalizedString(@"Weather", nil)];
        [_dataArr addObject:NSLocalizedString(@"Women Health", nil)];
        [_dataArr addObject:NSLocalizedString(@"Screen Display", nil)];
        [_dataArr addObject:NSLocalizedString(@"Watch Face", nil)];
        [_dataArr addObject:NSLocalizedString(@"Dial", nil)];
        [_dataArr addObject:NSLocalizedString(@"Sport Data Push", nil)];
        [_dataArr addObject:NSLocalizedString(@"QR Code", nil)];
        [_dataArr addObject:NSLocalizedString(@"Socail Contact", nil)];
        [_dataArr addObject:NSLocalizedString(@"History Data", nil)];
        [_dataArr addObject:NSLocalizedString(@"Contacts", nil)];
        [_dataArr addObject:NSLocalizedString(@"Bracelet Setting", nil)];
    }
    
    return _dataArr;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth-100, 50);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:NSLocalizedString(@"Synchronous Data", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return _formatter;
}
@end
