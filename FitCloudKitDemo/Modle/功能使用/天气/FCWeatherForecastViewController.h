//
//  FCWeatherForecastViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/7.
//

#import "FCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^refreshBlock)(void);
@interface FCWeatherForecastViewController : FCBaseViewController

@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, copy) refreshBlock refreshCallback;

@end

NS_ASSUME_NONNULL_END
