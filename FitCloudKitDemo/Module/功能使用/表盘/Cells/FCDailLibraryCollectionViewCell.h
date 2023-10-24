//
//  FCDailLibraryCollectionViewCell.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "FCDialLibraryModel.h"
#import "FCCommenCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCDailLibraryCollectionViewCell : UICollectionViewCell

- (void)configDailLibrary:(FCDialLibraryModel *)model;

- (void)configDail:(FCCommenCellModel *)model;

@end

NS_ASSUME_NONNULL_END
