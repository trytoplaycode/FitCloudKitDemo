//
//  FCHistoryDataViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/30.
//

#import "FCHistoryDataViewController.h"
#import "FCDefinitions.h"
#import "FCHistoryDataTableViewCell.h"
#import "FCCommenCellModel.h"
#import "FCCommenRecordModel.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <YYModel.h>
#import <BRPickerView.h>
#import <Masonry.h>
@interface FCHistoryDataViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *selectDate;

@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) UIView *emptyView;

@end

static NSString *identifier = @"history";
@implementation FCHistoryDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialization];
    [self loadData];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    self.selectDate = [self.formatter stringFromDate:[NSDate date]];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.dateButton];
    [self.view addSubview:self.emptyView];
    self.emptyView.hidden = YES;
}

- (void)loadData {
    NSMutableArray *arr = @[].mutableCopy;
    if (self.type == FCHistoryTypeStep) {
        arr = [[NSUserDefaults standardUserDefaults] objectForKey:kStepRecordList];
    }else if (self.type == FCHistoryTypeHeartRate) {
        [[NSUserDefaults standardUserDefaults] objectForKey:kHRRecordList];
    }else if (self.type == FCHistoryTypeBloodOxygen) {
        [[NSUserDefaults standardUserDefaults] objectForKey:kBORecordList];
    }else if (self.type == FCHistoryTypeBloodPressure) {
        [[NSUserDefaults standardUserDefaults] objectForKey:kBPRecordList];
    }else if (self.type == FCHistoryTypeSleep) {
        [[NSUserDefaults standardUserDefaults] objectForKey:kSleepRecordList];
    }else if (self.type == FCHistoryTypeSports) {
        [[NSUserDefaults standardUserDefaults] objectForKey:kSportsRecordList];
    }
    [self.dataArr removeAllObjects];
    for (NSInteger i = 0; i < arr.count; i++) {
        FCCommenRecordModel *model = [FCCommenRecordModel yy_modelWithJSON:arr[i]];
        NSString *modelYMD = [model.recordDate substringToIndex:10];
        if ([modelYMD isEqualToString:self.selectDate]) {
            [self.dataArr addObject:model];
        }
    }
    self.emptyView.hidden = self.dataArr.count > 0;
    [self.tableView reloadData];
}

#pragma mark - 点击事件
- (void)dateAction {
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeYMD title:NSLocalizedString(@"Date", nil) selectValue:self.selectDate resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        self.selectDate = selectValue;
        [self.dateButton setTitle:selectValue forState:UIControlStateNormal];
        [self loadData];
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCHistoryDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configHistory:self.dataArr[indexPath.row]];
    
    return cell;
}

#pragma mark -Set
- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    [self addNavBar:[NSString stringWithFormat:@"%@%@", titleString, NSLocalizedString(@"History Data", nil)]];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight+50, kScreenWidth, kScreenHeight-kTopBarHeight-50)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[FCHistoryDataTableViewCell class] forCellReuseIdentifier:identifier];
    }

    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
    }

    return _dataArr;
}

- (UIButton *)dateButton {
    if (!_dateButton) {
        _dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dateButton setTitleColor:UIColorWithRGB(0x333333, 1.f) forState:UIControlStateNormal];
        _dateButton.frame = CGRectMake(0, kTopBarHeight, 120, 50);
        _dateButton.titleLabel.font = FONT_MEDIUM(18);
        NSString *now = [self.formatter stringFromDate:[NSDate date]];
        [_dateButton setTitle:now forState:UIControlStateNormal];
        [_dateButton addTarget:self action:@selector(dateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _dateButton;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    return _formatter;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopBarHeight+50, kScreenWidth, kScreenHeight-kTopBarHeight)];
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
        label.numberOfLines = 2;
        label.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"No Data", nil), NSLocalizedString(@"Please make sure that synchronous watch data befor", nil)];
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

