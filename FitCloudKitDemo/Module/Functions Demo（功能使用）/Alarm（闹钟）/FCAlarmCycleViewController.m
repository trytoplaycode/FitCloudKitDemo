//
//  FCAlarmCycleViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/27.
//

#import "FCAlarmCycleViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCCommenCellModel.h"
#import "FCFuncListTableViewCell.h"
#import <FitCloudKit/FitCloudKit.h>

@interface FCAlarmCycleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;

@end

static NSString *identifier = @"cycle";
@implementation FCAlarmCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Alarm Cycle", nil)];
    [self initialization];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
}

#pragma mark - Actions
- (void)sureAction {
    Byte cycle = FITCLOUDALARMCYCLE_NONE;
    BOOL select = NO;
    for (FCCommenCellModel *model in self.dataArr) {
        if ([model.value intValue] == 1) {
            select = YES;
            break;
        }
    }
    
    if (!select) {
        cycle = FITCLOUDALARMCYCLE_NONE;
    }
    
    int selectCount = 0;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        if ([model.value intValue] == 1) {
            if (i == 0) {
                cycle = FITCLOUDALARMCYCLE_MON;
            }else if (i == 1) {
                if (selectCount == 0) {
                    cycle = FITCLOUDALARMCYCLE_TUE;
                }else {
                    cycle = cycle | FITCLOUDALARMCYCLE_TUE;
                }
            }else if (i == 2) {
                if (selectCount == 0) {
                    cycle = FITCLOUDALARMCYCLE_WED;
                }else {
                    cycle = cycle | FITCLOUDALARMCYCLE_WED;
                }
            }else if (i == 3) {
                if (selectCount == 0) {
                    cycle = FITCLOUDALARMCYCLE_THUR;
                }else {
                    cycle = cycle | FITCLOUDALARMCYCLE_THUR;
                }
            }else if (i == 4) {
                if (selectCount == 0) {
                    cycle = FITCLOUDALARMCYCLE_FRI;
                }else {
                    cycle = cycle | FITCLOUDALARMCYCLE_FRI;
                }
            }else if (i == 5) {
                if (selectCount == 0) {
                    cycle = FITCLOUDALARMCYCLE_SAT;
                }else {
                    cycle = cycle | FITCLOUDALARMCYCLE_SAT;
                }
            }else if (i == 6) {
                if (selectCount == 0) {
                    cycle = FITCLOUDALARMCYCLE_SUN;
                }else {
                    cycle = cycle | FITCLOUDALARMCYCLE_SUN;
                }
            }
            selectCount += 1;
        }
    }
    self.model.cycle = cycle;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleSelect];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.selectImageView.image = [model.value intValue] == 0 ? IMAGENAME(@"unselected") : IMAGENAME(@"selected");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    model.value = [model.value isEqualToString:@"0"] ? @"1" : @"0";
    [self.tableView reloadData];
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-100)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[FCFuncListTableViewCell class] forCellReuseIdentifier:identifier];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
        NSArray *arr = @[NSLocalizedString(@"Monday", nil),
                         NSLocalizedString(@"Tuesday", nil),
                         NSLocalizedString(@"Wednesday", nil),
                         NSLocalizedString(@"Thursday", nil),
                         NSLocalizedString(@"Friday", nil),
                         NSLocalizedString(@"Saturday", nil),
                         NSLocalizedString(@"Sunday", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            model.value = @"0";
            if (((self.model.cycle & FITCLOUDALARMCYCLE_MON) && i == 0)||
                ((self.model.cycle & FITCLOUDALARMCYCLE_TUE) && i == 1)||
                ((self.model.cycle & FITCLOUDALARMCYCLE_WED) && i == 2)||
                ((self.model.cycle & FITCLOUDALARMCYCLE_THUR) && i == 3)||
                ((self.model.cycle & FITCLOUDALARMCYCLE_FRI) && i == 4)||
                ((self.model.cycle & FITCLOUDALARMCYCLE_SAT) && i == 5)||
                ((self.model.cycle & FITCLOUDALARMCYCLE_SUN) && i == 6)) {
                model.value = @"1";
            }

            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth-100, 50);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:NSLocalizedString(@"Set", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}
@end

