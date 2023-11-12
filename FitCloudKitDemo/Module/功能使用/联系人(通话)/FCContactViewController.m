//
//  FCContactViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/31.
//

#import "FCContactViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import <BRPickerView.h>
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import "FCContactsDetailViewController.h"
#import <MBProgressHUD.h>
@interface FCContactViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, assign) BOOL editMode;

@end

static NSString *identifier = @"contact";
@implementation FCContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Contacts", nil)];
    [self addNavRightButton:NSLocalizedString(@"Delete", nil) isImage:NO];
    [self initialization];
    [self loadContacts];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {
    if (self.editMode) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSMutableArray *list = @[].mutableCopy;
        for (NSInteger i = 0; i < self.dataArr.count; i++) {
            FCCommenCellModel *model = self.dataArr[i];
            if (!model.isSelected) {
                FitCloudContactObject *contact = [FitCloudContactObject createWithName:model.title phone:model.value];
                [list addObject:contact];
            }
        }
        if (self.dataArr.count > list.count) {
            [FitCloudKit setFavContacts:list block:^(BOOL succeed, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadContacts];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    self.editMode = NO;
                    [self.rightButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
                    self.addButton.hidden = NO;
                    OpResultToastTip(self.view, succeed);
                });
            }];
        }else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.editMode = NO;
            [self.rightButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
            self.addButton.hidden = NO;
            [self.tableView reloadData];
        }
    }else {
        self.editMode = YES;
        [self.rightButton setTitle:NSLocalizedString(@"Sure", nil) forState:UIControlStateNormal];
        self.addButton.hidden = YES;
        [self.tableView reloadData];
    }
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addButton];
    [self.view addSubview:self.emptyView];
    self.emptyView.hidden = YES;
}

- (void)loadContacts {
    weakSelf(weakSelf);
    [FitCloudKit getFavContactsWithBlock:^(BOOL succeed, NSArray<FitCloudContactObject *> *list, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArr removeAllObjects];
            for (NSInteger i = 0; i < list.count; i++) {
                FitCloudContactObject *obj = list[i];
                FCCommenCellModel *model = [FCCommenCellModel new];
                model.title = obj.name;
                model.value = obj.phone;
                [weakSelf.dataArr addObject:model];
            }
            weakSelf.emptyView.hidden = weakSelf.dataArr.count > 0;
            [weakSelf.tableView reloadData];
        });
    }];
}

#pragma mark -点击事件
- (void)addAction {
    weakSelf(weakSelf);
    FCContactsDetailViewController *detail = [FCContactsDetailViewController new];
    detail.dataArr = self.dataArr;
    detail.addContactsCallback = ^(FCCommenCellModel * _Nonnull model) {
        [weakSelf.dataArr addObject:model];
        weakSelf.emptyView.hidden = weakSelf.dataArr.count > 0;
        [weakSelf.tableView reloadData];
        [weakSelf sureAction];
    };
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)sureAction {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableArray *list = @[].mutableCopy;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        FitCloudContactObject *contact = [FitCloudContactObject createWithName:model.title phone:model.value];
        if (contact) {
            [list addObject:contact];
        }
    }
    [FitCloudKit setFavContacts:list block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            OpResultToastTip(self.view, succeed);
        });
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:self.editMode?FCCellStyleSelect:FCCellStyleNormal];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.valueLabel.text = model.value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    if (self.editMode) {
        FCFuncListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        model.isSelected = !model.isSelected;
        cell.selectImageView.image = model.isSelected ? IMAGENAME(@"selected") : IMAGENAME(@"unselected");
    }else {
        FCContactsDetailViewController *detail = [FCContactsDetailViewController new];
        detail.indexPath = indexPath;
        detail.model = model;
        weakSelf(weakSelf);
        detail.editContactsCallback = ^(FCCommenCellModel * _Nonnull model, NSIndexPath * _Nonnull indexPath) {
            [weakSelf.dataArr replaceObjectAtIndex:indexPath.row withObject:model];
            [weakSelf.tableView reloadData];
            [weakSelf sureAction];
        };
        detail.deleteContactsCallback = ^(FCCommenCellModel * _Nonnull model) {
            [weakSelf.dataArr removeObject:model];
            [weakSelf.tableView reloadData];
            [weakSelf sureAction];
        };
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - 长按排序
- (void)longPressRecognizer:(UILongPressGestureRecognizer *)longPress{
    //获取长按的点及cell
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UIGestureRecognizerState state = longPress.state;
    static UIView *snapView = nil;
    static NSIndexPath *sourceIndex = nil;
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            if (indexPath) {
                sourceIndex = indexPath;
                FCFuncListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                snapView = [self customViewWithTargetView:cell];
                __block CGPoint center = cell.center;
                snapView.center = center;
                snapView.alpha = 0.0;
                [self.tableView addSubview:snapView];
                [UIView animateWithDuration:0.1 animations:^{
                    center.y = location.y;
                    snapView.center = center;
                    snapView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapView.alpha = 0.5;
                    cell.alpha = 0.0;
                }];
            }
        }
        break;
        case UIGestureRecognizerStateChanged:{
            CGPoint center = snapView.center;
            center.y = location.y;
            snapView.center = center;
            FCFuncListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndex];
            cell.alpha = 0.0;
            if (indexPath && ![indexPath isEqual:sourceIndex]) {
                [self.dataArr exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndex.row];
                [self.tableView moveRowAtIndexPath:sourceIndex toIndexPath:indexPath];
                sourceIndex = indexPath;
            }
        }
        break;
        default:{
            FCFuncListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndex];
            [UIView animateWithDuration:0.25 animations:^{
                snapView.center = cell.center;
                snapView.transform = CGAffineTransformIdentity;
                snapView.alpha = 0.0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                [snapView removeFromSuperview];
                snapView = nil;
            }];
            sourceIndex = nil;
            [self sureAction];
        }
        break;
    }
}

//截取选中cell
- (UIView *)customViewWithTargetView:(UIView *)target{
    UIGraphicsBeginImageContextWithOptions(target.bounds.size, NO, 0);
    [target.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-100)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[FCFuncListTableViewCell class] forCellReuseIdentifier:identifier];
        // 添加长按手势
         UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressRecognizer:)];
         longPress.minimumPressDuration = 0.3;
        [_tableView addGestureRecognizer:longPress];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
    }
    
    return _dataArr;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth-100, 50);
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addButton setTitle:NSLocalizedString(@"Add Contacts", nil) forState:UIControlStateNormal];
        _addButton.clipsToBounds = YES;
        _addButton.layer.cornerRadius = 8;
        _addButton.backgroundColor = [UIColor systemBlueColor];
        [_addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.addButton.frame)+20, kScreenWidth-100, 50);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-170)];
        _emptyView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [UIImageView new];
        imageView.image = IMAGENAME(@"empty");
        [_emptyView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView);
            make.centerY.mas_equalTo(_emptyView.mas_centerY).offset(-15);
            make.size.mas_equalTo(CGSizeMake(101, 84));
        }];
        UILabel *label = [UILabel new];
        label.textColor = UIColorFromRGB(0x999999, 1.f);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = FONT_MEDIUM(16);
        label.numberOfLines = 1;
        label.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"No Data", nil)];
        [_emptyView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView);
            make.top.mas_equalTo(imageView.mas_bottom).offset(10);
            make.width.mas_equalTo(240);
        }];
    }
    
    return _emptyView;
}
@end

