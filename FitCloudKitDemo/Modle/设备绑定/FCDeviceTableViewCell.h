//
//  FCDeviceTableViewCell.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/20.
//

#import <UIKit/UIKit.h>
#import <FitCloudKit/FitCloudKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FCDeviceTableViewCell : UITableViewCell

- (void)configDevice:(FitCloudPeripheral *)peripheral showStatus:(BOOL)showStatus;

@end

NS_ASSUME_NONNULL_END
