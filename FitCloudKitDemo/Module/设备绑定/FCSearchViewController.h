//
//  FCSearchViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCSearchViewController : FCBaseViewController
/// 当前步骤 0 搜索 1 搜索完毕
@property (nonatomic, assign) NSInteger step;

@end

NS_ASSUME_NONNULL_END
