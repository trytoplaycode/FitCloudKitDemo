//
//  FCSearchViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCSearchViewController.h"
#import <FitCloudKit/FitCloudKit.h>
#import "FCDefinitions.h"
#import <NSDictionary+YYAdd.h>
#import "FCDeviceBindViewController.h"
#import "FCFuncListViewController.h"
#import <YYModel.h>
#import "FCGlobal.h"
@interface FCSearchViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageSmartWatch;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnConnectDevice;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *progressTip;
@property (weak, nonatomic) IBOutlet UILabel *soc;
@property (weak, nonatomic) IBOutlet UIButton *btnRemoveDevice;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreDemo;
@property (weak, nonatomic) IBOutlet UIView *searchTipsView;
@property (assign, nonatomic) BOOL sysFinished;

@end

@implementation FCSearchViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sysFinished = NO;
    self.btnSearch.clipsToBounds = YES;
    self.btnSearch.layer.borderWidth = 1;
    self.btnSearch.layer.borderColor = self.btnSearch.titleLabel.textColor.CGColor;
    self.btnSearch.layer.cornerRadius = 25;
    self.btnRemoveDevice.titleLabel.font = FONT_REGULAR(11);
    self.btnMoreDemo.titleLabel.font = FONT_REGULAR(11);
    [self setNavBarClear];
    {
        [self.btnConnectDevice setTitle:NSLocalizedString(@"Connect Device", nil) forState:UIControlStateNormal];
        self.btnConnectDevice.layer.borderColor = UIColor.blackColor.CGColor;
        [self.btnConnectDevice setContentEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 30)];
    }
    {
        [self.btnSearch setTitle:NSLocalizedString(@"Search Device", nil) forState:UIControlStateNormal];
        self.btnSearch.layer.borderColor = UIColor.blackColor.CGColor;
        [self.btnSearch setContentEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 30)];
    }
    
    {
        [self.btnRemoveDevice setTitle:NSLocalizedString(@"Remove Device", nil) forState:UIControlStateNormal];
    }
    
    {
        [self.btnMoreDemo setTitle:NSLocalizedString(@"More Demo >", nil) forState:UIControlStateNormal];
    }
    
    {
        [self updateControlVisible];
    }
    
    [self registerNotificationObsever];
     if([FitCloudKit lastConnectPeripheral])
     {
         self.deviceName.text = [FitCloudKit lastConnectPeripheral].name;
         if([FitCloudKit connecting])
         {
             self.indicator.hidden = self.connectStatus.hidden = FALSE;
             if(!self.indicator.isAnimating)[self.indicator startAnimating];
             self.btnConnectDevice.hidden = TRUE;
             self.btnRemoveDevice.hidden = TRUE;
             self.btnMoreDemo.hidden = TRUE;
             self.connectStatus.text = NSLocalizedString(@"Connecting...", nil);
             self.connectStatus.textColor = RGB(0x9A, 0x9A, 0x9A);
             self.indicator.hidden = YES;
         }
     }
}

-(void) registerNotificationObsever
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPeripheralConnectingNotification:) name:FITCLOUDEVENT_PERIPHERAL_CONNECTING_NOTIFY object:nil];
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

-(void)OnPeripheralConnectingNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicator.hidden = self.connectStatus.hidden = FALSE;
        if(!self.indicator.isAnimating)[self.indicator startAnimating];
        self.btnConnectDevice.hidden = TRUE;
        self.btnRemoveDevice.hidden = TRUE;
        self.btnMoreDemo.hidden = TRUE;
        self.connectStatus.text = NSLocalizedString(@"Connecting...", nil);
        self.connectStatus.textColor = RGB(0x9A, 0x9A, 0x9A);
        self.indicator.hidden = YES;
    });
}

-(void)OnPeripheralConnectedNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int bindStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bindStatus"] intValue];
        [FCGlobal shareInstance].currentPeripheral = notification.object;
        if (bindStatus == 0) {
            self.imageSmartWatch.hidden = self.deviceName.hidden = self.indicator.hidden = self.connectStatus.hidden = self.btnConnectDevice.hidden = self.btnRemoveDevice.hidden = self.btnMoreDemo.hidden = TRUE;
            self.btnSearch.hidden = NO;
            self.searchTipsView.hidden = NO;
            self.indicator.hidden = YES;
        }else {
            if(self.indicator.isAnimating)[self.indicator stopAnimating];
            self.connectStatus.text = NSLocalizedString(@"Connected", nil);
            self.connectStatus.textColor = RGB(0x00, 0xB2, 0x00);
            self.btnConnectDevice.hidden = TRUE;
            self.imageSmartWatch.hidden = self.deviceName.hidden = FALSE;
            self.btnSearch.hidden = YES;
            self.searchTipsView.hidden = YES;
        }
        self.btnRemoveDevice.hidden = FALSE;
    });
}

-(void)OnPeripheralDisconnectedNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.indicator.isAnimating)[self.indicator stopAnimating];
        self.connectStatus.text = NSLocalizedString(@"Disconnected", nil);
        self.connectStatus.textColor = RGB(0x9A, 0x9A, 0x9A);
        if([FitCloudKit lastConnectPeripheral])self.btnConnectDevice.hidden = FALSE;
        self.btnRemoveDevice.hidden = YES;
        self.btnMoreDemo.hidden = YES;
        self.soc.text = @"";
    });
}

-(void)OnPeripherialConnectFailureNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.indicator.isAnimating)[self.indicator stopAnimating];
        self.btnConnectDevice.hidden = FALSE;
        self.connectStatus.text = NSLocalizedString(@"Disconnected", nil);
        self.connectStatus.textColor = RGB(0x9A, 0x9A, 0x9A);
    });
}

-(void)OnBatteryInfoNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FitCloudBatteryInfoObject *batteryInfo = notification.object;
        if([batteryInfo isKindOfClass:[FitCloudBatteryInfoObject class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                 self.soc.text = [NSString stringWithFormat:NSLocalizedString(@"SOC: %@%%", nil), @(batteryInfo.percent)];
            });
        }
    });
}

-(void)OnFitCloudLoginUserObjectBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressTip.text = NSLocalizedString(@"Logging On User Object", nil);
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
        self.progressTip.text = result ? NSLocalizedString(@"Login User Object Success", nil) : NSLocalizedString(@"Login User Object Failure", nil);
    });
}

-(void)OnFitCloudGetAllConfigBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressTip.text = NSLocalizedString(@"Getting Smart Watch All Config", nil);
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
        self.progressTip.text = result ? NSLocalizedString(@"Get Smart Watch All Config Success", nil) : NSLocalizedString(@"Get Smart Watch All Config Failure", nil);
    });
}

-(void)OnPrepareSyncWorkBeginNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressTip.text = NSLocalizedString(@"Preparing Work for Smart Watch", nil);
    });
}

-(void)OnPrepareSyncWorkEndNotification:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInfoList];
        NSString *userInfo = [info objectForKey:[info.allKeys firstObject]];
        FitCloudUserProfileObject *obj = [FitCloudUserProfileObject yy_modelWithJSON:userInfo];
        if (obj) {
            [FitCloudKit setUserProfile:obj block:^(BOOL succeed, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"设置用户信息成功");
                });
            }];
        }
        
        self.step = 1;
        self.btnRemoveDevice.hidden = FALSE;
        self.btnMoreDemo.hidden = FALSE;
        self.sysFinished = YES;
        self.progressTip.text = NSLocalizedString(@"Prepare Work for Smart Watch Finished.", nil);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.5f animations:^{
                self.progressTip.alpha = 0;
            } completion:^(BOOL finished) {
                self.progressTip.text = @"";
                self.progressTip.alpha = 1;
            }];
        });
    });
}

-(void) updateControlVisible
{
    if(![FitCloudKit lastConnectPeripheral])
    {
        self.imageSmartWatch.hidden = self.deviceName.hidden = self.indicator.hidden = self.connectStatus.hidden = self.btnConnectDevice.hidden = self.btnRemoveDevice.hidden = self.btnMoreDemo.hidden = TRUE;
        self.btnSearch.hidden = NO;
        self.searchTipsView.hidden = NO;
        self.indicator.hidden = YES;
    }
    else
    {
        self.imageSmartWatch.hidden = self.deviceName.hidden = FALSE;
        self.btnSearch.hidden = YES;
        self.searchTipsView.hidden = YES;
    }
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

#pragma mark -点击事件
- (IBAction)OnConnectDevice:(id)sender {
    self.indicator.hidden = self.connectStatus.hidden = FALSE;
    self.indicator.hidden = YES;
    [self.indicator startAnimating];
    self.btnConnectDevice.hidden = TRUE;
    [FitCloudKit tryConnect:[[FitCloudKit historyPeripherals] lastObject]];
}

- (IBAction)searchAction:(id)sender {
    FCDeviceBindViewController *device = [FCDeviceBindViewController new];
    [self.navigationController pushViewController:device animated:YES];
}

- (IBAction)removeDeviceAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    [FitCloudKit unbindUserObject:YES block:^(BOOL succeed, NSError *error) {
        FitCloudKitConnectRecord *record = [[FitCloudKit historyPeripherals] lastObject];
        [FitCloudKit removePeripheralHistoryWithUUID:record.uuid.UUIDString];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.step = 0;
            [FCGlobal shareInstance].currentPeripheral = nil;
            [weakSelf updateControlVisible];
        });
    }];
}

- (IBAction)moreDemoAction:(id)sender {
    FCFuncListViewController *func = [FCFuncListViewController new];
    [self.navigationController pushViewController:func animated:YES];
}

@end
