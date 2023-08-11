//
//  FCFuncListTableViewCell.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import <UIKit/UIKit.h>
#import "LocalizedLabel.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, FCCellStyle) {
    FCCellStyleNone,
    FCCellStyleNormal,
    FCCellStyleSwitchs,
    FCCellStyleSelect,
};

@interface FCFuncListTableViewCell : UITableViewCell

@property (nonatomic, strong) LocalizedLabel *nameLabel;
@property (nonatomic, strong) LocalizedLabel *valueLabel;
@property (nonatomic, strong) UISwitch *switchs;
@property (nonatomic, strong) UIImageView *selectImageView;

- (void)configCellStyle:(FCCellStyle)style;

@end

NS_ASSUME_NONNULL_END
