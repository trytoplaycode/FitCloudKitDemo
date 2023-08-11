//
//  FCContactsDetailViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/31.
//

#import "FCBaseViewController.h"
#import "FCCommenCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^addContactsBlock)(FCCommenCellModel *model);
typedef void (^editContactsBlock)(FCCommenCellModel *model, NSIndexPath *indexPath);
typedef void (^deleteContactsBlock)(FCCommenCellModel *model);

@interface FCContactsDetailViewController : FCBaseViewController

@property (nonatomic, strong) FCCommenCellModel *model;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) addContactsBlock addContactsCallback;
@property (nonatomic, copy) editContactsBlock editContactsCallback;
@property (nonatomic, copy) deleteContactsBlock deleteContactsCallback;

@end

NS_ASSUME_NONNULL_END
