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

/** 点击事件 */
@property (nonatomic, copy) centerButtonClickBlock centerButtonCallback;
/** tabbar按钮显示信息 */
@property(copy, nonatomic) NSArray<UITabBarItem *> *items;
/** 设置文字颜色 */
@property (strong , nonatomic) UIColor *textColor;
/** 设置选中颜色 */
@property (strong , nonatomic) UIColor *selectedTextColor;
/** 其他按钮 */
@property (strong , nonatomic) NSMutableArray <FCButton*> *btnArr;
/** 中间按钮 */
@property (strong , nonatomic) FCCenterButton *centerBtn;
/** 按钮索引 */
@property (assign, nonatomic) NSUInteger selectButtoIndex;

- (void)setBrigdAtIndex:(NSInteger)index;

- (void)hiddenBrigdAtIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
