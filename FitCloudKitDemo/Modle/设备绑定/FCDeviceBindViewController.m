//
//  FCDeviceBindViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/15.
//

#import "FCDeviceBindViewController.h"
#import <FitCloudKit/FitCloudKit.h>
#import <NSDictionary+YYAdd.h>
#import "FCDeviceTableViewCell.h"
#import "FCDefinitions.h"
#import "FCDeviceBindingViewController.h"
#import <MBProgressHUD.h>
#import "FCGlobal.h"
@interface FCDeviceBindViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

static NSString *identifier = @"device";
@implementation FCDeviceBindViewController

-(void)dealloc {
    [FitCloudKit stopScan];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavRightButton:NSLocalizedString(@"Refresh", nil) isImage:NO];
    [self addNavBar:NSLocalizedString(@"Device List", nil)];
    [self setNavBackWhite];
    [self initialization];
    [self registerNotificationObsever];
    [FitCloudKit scanPeripherals];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {
    [FitCloudKit scanPeripherals];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
}

-(void) registerNotificationObsever {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralDiscoveredNotification:) name:FITCLOUDEVENT_PERIPHERAL_DISCOVERED_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralDiscoveredUpdatedNotification:) name:FITCLOUDEVENT_PERIPHERAL_DISCOVERED_UPDATED_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralScanStopNotification:) name:FITCLOUDEVENT_PERIPHERAL_SCANSTOP_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudWriteCharacteristicReady:) name:FITCLOUDEVENT_PERIPHERAL_WRITECHARACTERISTIC_READY_NOTIFIY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralConnectingNotification:) name:FITCLOUDEVENT_PERIPHERAL_CONNECTING_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralConnectFailureNotification:) name:FITCLOUDEVENT_PERIPHERAL_CONNECT_FAILURE_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralConnectedNotification:) name:FITCLOUDEVENT_PERIPHERAL_CONNECTED_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralDisconnectedNotification:) name:FITCLOUDEVENT_PERIPHERAL_DISCONNECT_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripherialConnectFailureNotification:) name:FITCLOUDEVENT_PERIPHERAL_CONNECT_FAILURE_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBatteryInfoNotification:) name:FTICLOUDEVENT_BATTERYINFO_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudLoginUserObjectBegin:) name:FITCLOUDEVENT_LOGINUSEROBJECT_BEGIN_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudLoginUserObjectResult:) name:FITCLOUDEVENT_LOGINUSEROBJECT_RESULT_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudGetAllConfigBegin:) name:FITCLOUDEVENT_GETALLCONFIG_BEGIN_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudGetAllConfigResult:) name:FITCLOUDEVENT_GETALLCONFIG_RESULT_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPrepareSyncWorkBeginNotification:) name:FITCLOUDEVENT_PREPARESYNCWORK_BEGIN_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPrepareSyncWorkEndNotification:) name:FITCLOUDEVENT_PREPARESYNCWORK_END_NOTIFY object:nil];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
#if TARGET_IPHONE_SIMULATOR//模拟器
    return FALSE;
#else
    if([FitCloudKit bleState] != FITCLOUDBLECENTRALSTATE_POWEREDON)
    {
        if([FitCloudKit bleState] == FITCLOUDBLECENTRALSTATE_POWEREDOFF)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
        else
        {
            [FitCloudKit requestShowBluetoothPowerAlert];
        }
        return FALSE;
    }
    return TRUE;
#endif
}

#pragma mark - 设备搜索
-(void)OnFitCloudWriteCharacteristicReady:(NSNotification*) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FCDeviceBindingViewController* bindingVC = [FCDeviceBindingViewController new];
        [self.navigationController pushViewController:bindingVC animated:YES];
    });
}

-(void) OnPeripheralDiscoveredNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([notification.object isKindOfClass:[FitCloudPeripheral class]])
        {
            NSLog(@"搜索到设备");
            FitCloudPeripheral *per = (FitCloudPeripheral *)notification.object;
            BOOL exist = NO;
            for (FitCloudPeripheral *model in self.peripherals) {
                if ([model.peripheral.name isEqualToString:per.peripheral.name]) {
                    exist = YES;
                    break;;
                }
            }
            if (!exist) {
                [self.peripherals addObject:notification.object];
                [self.tableView reloadData];
            }
        }
    });
}

-(void) OnPeripheralDiscoveredUpdatedNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([notification.object isKindOfClass:[FitCloudPeripheral class]])
        {
//            FitCloudPeripheral *fcPeripheral = notification.object;
//            __weak typeof(self) weakSelf = self;
//            [self.peripherals enumerateObjectsUsingBlock:^(FitCloudPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if(fcPeripheral == obj)
//                {
//                    [weakSelf.tableView beginUpdates];
//                    NSMutableArray<NSIndexPath*>*array = [NSMutableArray<NSIndexPath*> array];
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//                    [array addObject:indexPath];
//                    [weakSelf.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [weakSelf.tableView endUpdates];
//                    *stop = YES;
//                }
//            }];
        }
    });
}

-(void) OnPeripheralScanStopNotification:(NSNotification*)notification
{
    if([FitCloudKit bleState] == FITCLOUDBLECENTRALSTATE_POWEREDON)
    {
        
    }
}

#pragma mark - 设备连接
-(void)OnPeripheralConnectingNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

-(void)OnPeripheralConnectedNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.peripherals.count == 0 && [notification.object isKindOfClass:[FitCloudPeripheral class]]) {
//            self.searchView.hidden = YES;
//            self.tableView.hidden = NO;
//            [self.peripherals addObject:notification.object];
//            [self.tableView reloadData];
//        }
    });
}


-(void) OnPeripheralConnectFailureNotification:(NSNotification *)notification
{
    //self.shouldHideSkipBtn = NO;
    //[self setupNaviBar];
}


-(void)OnPeripheralDisconnectedNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

-(void)OnPeripherialConnectFailureNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

-(void)OnBatteryInfoNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FitCloudBatteryInfoObject *batteryInfo = notification.object;
        if([batteryInfo isKindOfClass:[FitCloudBatteryInfoObject class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }
    });
}

-(void)OnFitCloudLoginUserObjectBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

-(void)OnFitCloudLoginUserObjectResult:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL result = NO;
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo isKindOfClass:[NSDictionary class]])
        {
            result = [userInfo boolValueForKey:@"result" default:NO];
        }

    });
}

-(void)OnFitCloudGetAllConfigBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

-(void)OnFitCloudGetAllConfigResult:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL result = NO;
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo isKindOfClass:[NSDictionary class]])
        {
            result = [userInfo boolValueForKey:@"result" default:NO];
        }
    });
}

-(void)OnPrepareSyncWorkBeginNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

-(void)OnPrepareSyncWorkEndNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            
        });
    });
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configDevice:self.peripherals[indexPath.row] showStatus:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0)
    {
        if ([self.peripherals isKindOfClass:[NSArray class]] && [self.peripherals count] > indexPath.row)
        {
            
            FitCloudPeripheral* item = [self.peripherals objectAtIndex:indexPath.row];
            if([item isKindOfClass:[FitCloudPeripheral class]] && item.peripheral.state != CBPeripheralStateConnecting && (item.peripheral.state != CBPeripheralStateConnected || item.paired))
            {
                [FitCloudKit connect:item.peripheral];
                [FCGlobal shareInstance].currentPeripheral = item.peripheral;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
        }
    }
}
#pragma mark - 懒加载
- (NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = @[].mutableCopy;
    }
    
    return _peripherals;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navBackView.frame.size.height, kScreenWidth, kScreenHeight-self.navBackView.frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 65;
        [_tableView registerClass:[FCDeviceTableViewCell class] forCellReuseIdentifier:identifier];
    }
    
    return _tableView;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] init];
        _hud.label.text = @"刷新中";
    }
    
    return _hud;
}

@end
