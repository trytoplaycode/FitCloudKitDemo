//
//  FCHistoryDataViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/30.
//

#import "FCBaseViewController.h"
#import "FCDefinitions.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCHistoryDataViewController : FCBaseViewController

@property (nonatomic, assign) FCHistoryType type;
@property (nonatomic, copy) NSString *titleString;

@end

NS_ASSUME_NONNULL_END
