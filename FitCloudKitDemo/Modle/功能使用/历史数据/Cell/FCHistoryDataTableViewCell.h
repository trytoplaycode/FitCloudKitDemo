//
//  FCHistoryDataTableViewCell.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import <UIKit/UIKit.h>
#import "FCCommenRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCHistoryDataTableViewCell : UITableViewCell

- (void)configHistory:(FCCommenRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
