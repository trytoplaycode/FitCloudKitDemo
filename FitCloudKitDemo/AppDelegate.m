//
//  AppDelegate.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "AppDelegate.h"
#import "FCBaseNavigationViewController.h"
#import "FCLoginViewController.h"
#import "FCDefinitions.h"
#import "AppDelegate+FitCloudKit.h"
#import "AppDelegate+LoggerService.h"
#import "FCSearchViewController.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bugly startWithAppId:@"ef17b412e6"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    int login = [[[NSUserDefaults standardUserDefaults] objectForKey:kLoginFlag] intValue];
    if (login) {
        NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kBindDevice];
        if (info) {
            FCBaseNavigationViewController *nav = [[FCBaseNavigationViewController alloc] initWithRootViewController:[FCLoginViewController new]];
            self.window.rootViewController = nav;
        }else {
            FCBaseNavigationViewController *nav = [[FCBaseNavigationViewController alloc] initWithRootViewController:[FCSearchViewController new]];
            self.window.rootViewController = nav;
        }
    }else {
        FCBaseNavigationViewController *nav = [[FCBaseNavigationViewController alloc] initWithRootViewController:[FCLoginViewController new]];
        self.window.rootViewController = nav;
    }
    [self.window makeKeyAndVisible];
    [self loggerServiceConfig];
    [self fitCloudKitConfig];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    int bindStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bindStatus"] intValue];
    if (bindStatus == 0) {
        [FitCloudKit ignoreConnectedPeripheral:YES];
        [FitCloudKit clearPeripheralHistory];
        [FitCloudKit unbindUserObject:YES block:^(BOOL succeed, NSError *error) {
            FitCloudKitConnectRecord *record = [[FitCloudKit historyPeripherals] lastObject];
            [FitCloudKit removePeripheralHistoryWithUUID:record.uuid.UUIDString];
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }];
    }
}

- (void)OnAlexaVoiceStartRequestWithCompletion:(FitCloudAlexaVoiceStartRequestCompletion)completion {
    NSLog(@"123");
}

- (void)OnAlexaVoiceDecodeBegin {
    NSLog(@"123");
}

- (void)OnAlexaVoiceFinish:(NSInteger)length crc:(NSInteger)crc {
    NSLog(@"123");
}
@end
