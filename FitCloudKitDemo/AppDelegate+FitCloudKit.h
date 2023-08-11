//
//  AppDelegate+FitCloudKit.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/18.
//

#import "AppDelegate.h"
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (FitCloudKit)<FitCloudCallback>

-(void) fitCloudKitConfig;

@end

NS_ASSUME_NONNULL_END
