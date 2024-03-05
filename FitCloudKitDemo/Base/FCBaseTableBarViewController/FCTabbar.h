//
//  FCTabbar.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import <UIKit/UIKit.h>
@class FCCenterButton;
@class FCButton;
NS_ASSUME_NONNULL_BEGIN

typedef void (^centerButtonClickBlock)(void);
@interface FCTabbar : UIImageView

/** 点击事件（click action） */
@property (nonatomic, copy) centerButtonClickBlock centerButtonCallback;
/** tabbar items */
@property(copy, nonatomic) NSArray<UITabBarItem *> *items;
/** text color */
@property (strong , nonatomic) UIColor *textColor;
/** select text color */
@property (strong , nonatomic) UIColor *selectedTextColor;
/** other buttons */
@property (strong , nonatomic) NSMutableArray <FCButton*> *btnArr;
/** center button */
@property (strong , nonatomic) FCCenterButton *centerBtn;
/** select index */
@property (assign, nonatomic) NSUInteger selectButtoIndex;

- (void)setBrigdAtIndex:(NSInteger)index;

- (void)hiddenBrigdAtIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
