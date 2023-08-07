//
//  FCAlarmDetailViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/26.
//

#import "FCBaseViewController.h"
#import <FitCloudKit/FitCloudKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FCAlarmDetailViewController : FCBaseViewController

@property (nonatomic, strong) FitCloudAlarmObject *model;

@end

NS_ASSUME_NONNULL_END
