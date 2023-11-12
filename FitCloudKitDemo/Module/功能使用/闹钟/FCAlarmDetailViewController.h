//
//  FCAlarmListViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/26.
//

#import "FCBaseViewController.h"
#import <FitCloudKit/FitCloudKit.h>

typedef void (^refreshBlock)(void);
NS_ASSUME_NONNULL_BEGIN
@interface FCAlarmDetailViewController : FCBaseViewController

@property (nonatomic, copy) refreshBlock refreshCallback;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
