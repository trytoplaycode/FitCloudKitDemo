//
//  FCWomenHealthyViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/27.
//

#import "FCWomenHealthyViewController.h"
#import "FCDefinitions.h"
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import <BRPickerView.h>
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface FCWomenHealthyViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) NSMutableArray *dayArr;
@end

static NSString *identifier = @"women";
@implementation FCWomenHealthyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Women Health", nil)];
    [self initialization];
    [self loadWomenHealthSettings];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
}

- (NSString *)convertIntervalToTime:(UInt16)interval {
    int hour = interval/60;
    int min = interval%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", hour, min];
}

- (int)convertTimeToInterval:(NSString *)time {
    NSArray *arr = [time componentsSeparatedByString:@":"];
    if (arr.count != 2) {return 0;}
    NSString *hour = [arr firstObject];
    NSString *min = [arr lastObject];
    
    return [hour intValue]*60+[min intValue];
}


- (void)loadWomenHealthSettings {
    weakSelf(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FitCloudKit getWomenHealthSettingWithBlock:^(BOOL succeed, FitCloudWomenHealthSetting *whSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (whSetting) {
                NSString *status = whSetting.mode == WOMENHEALTHMODE_MENSES ? NSLocalizedString(@"Open", nil) : NSLocalizedString(@"Close", nil);
                NSArray *arr = @[status, [NSString stringWithFormat:@"%d", whSetting.advanceDaysToRemind],[self convertIntervalToTime:whSetting.offsetMinutesInDayOfRemind],[NSString stringWithFormat:@"%d", whSetting.mensesDuration], [NSString stringWithFormat:@"%d", whSetting.menstrualCycle],whSetting.recentMenstruationBegin?:@"",[NSString stringWithFormat:@"%d", whSetting.daysOfFinishSinceMensesBegin]];
                for (NSInteger i = 0; i < weakSelf.dataArr.count; i++) {
                    FCCommenCellModel *model = weakSelf.dataArr[i];
                    model.value = arr[i];
                }
            }else {
                NSString *status = whSetting.mode == WOMENHEALTHMODE_MENSES ? NSLocalizedString(@"Open", nil) : NSLocalizedString(@"Close", nil);
                NSArray *arr = @[status, [NSString stringWithFormat:@"%d", whSetting.advanceDaysToRemind],[self convertIntervalToTime:whSetting.offsetMinutesInDayOfRemind],[NSString stringWithFormat:@"%d", whSetting.mensesDuration], [NSString stringWithFormat:@"%d", whSetting.menstrualCycle],whSetting.recentMenstruationBegin?:@"",[NSString stringWithFormat:@"%d", whSetting.daysOfFinishSinceMensesBegin]];
                
                NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kWomenHealthy];
                if (info) {
                    NSString *mode = [info objectForKey:@"mode"]?:@"";
                    int remindDay = [[info objectForKey:@"remindDay"] intValue];
                    NSString *time = [info objectForKey:@"time"];
                    int duration = [[info objectForKey:@"duration"] intValue];
                    int cycle = [[info objectForKey:@"cycle"] intValue];
                    NSString *recent = [info objectForKey:@"recent"] ? : @"";
                    int last = [[info objectForKey:@"last"] intValue];
                    status = mode;
                    arr = @[status, [NSString stringWithFormat:@"%d", remindDay],time,[NSString stringWithFormat:@"%d", duration], [NSString stringWithFormat:@"%d", cycle],recent,[NSString stringWithFormat:@"%d", last]];
                }
                for (NSInteger i = 0; i < weakSelf.dataArr.count; i++) {
                    FCCommenCellModel *model = weakSelf.dataArr[i];
                    model.value = arr[i];
                }
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)sureAction {
    FCCommenCellModel *mode = self.dataArr[0];
    FCCommenCellModel *remindDay = self.dataArr[1];
    FCCommenCellModel *time = self.dataArr[2];
    FCCommenCellModel *duration = self.dataArr[3];
    FCCommenCellModel *cycle = self.dataArr[4];
    FCCommenCellModel *recent = self.dataArr[5];
    FCCommenCellModel *last = self.dataArr[6];
    FitCloudWomenHealthSetting *health = [FitCloudWomenHealthSetting settingwithMode:[mode.value isEqualToString:NSLocalizedString(@"Open", nil)] ? WOMENHEALTHMODE_MENSES : WOMENHEALTHMODE_OFF advanceDaysToRemind:[remindDay.value intValue] offsetMinutesInDayOfRemind:[self convertTimeToInterval:time.value] mensesDuration:[duration.value intValue] menstrualCycle:[cycle.value intValue] recentMenstruationBegin:recent.value?:@"" daysOfFinishSinceMensesBegin:[last.value intValue] pregancyRemindType:PREGNANCYREMINDTYPE_PREGNANTDAYS];
    weakSelf(weakSelf);
    [FitCloudKit setWomenHealthConfig:health block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
            NSDictionary *info = @{@"mode":mode.value?:@"", @"remindDay":remindDay.value?:@"", @"time":time.value?:@"", @"duration":duration.value?:@"", @"cycle":cycle.value?:@"", @"recent":recent.value?:@"", @"last":last.value?:@""};
            [[NSUserDefaults standardUserDefaults] setObject:info forKey:kWomenHealthy];
            [weakSelf loadWomenHealthSettings];
        });
    }];

}
#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleNormal];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.valueLabel.text = model.value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block FCCommenCellModel *model = self.dataArr[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:@[NSLocalizedString(@"Open", nil), NSLocalizedString(@"Close", nil)] selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 1:
        {
            NSInteger index = [model.value integerValue];
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.dayArr selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 2:
        {
            [BRDatePickerView showDatePickerWithMode:BRDatePickerModeHM title:model.title selectValue:model.value resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
                model.value = selectValue;
                [self.tableView reloadData];
            }];
        }
            break;
        case 3:
        {
            NSInteger index = [model.value integerValue];
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.dayArr selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 4:
        {
            NSInteger index = [model.value integerValue];
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.dayArr selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 5:
        {
            [BRDatePickerView showDatePickerWithMode:BRDatePickerModeYMD title:model.title selectValue:model.value.length > 0 ? model.value : nil resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
                model.value = selectValue;
                [self.tableView reloadData];
            }];
        }
            break;
        case 6:
        {
            NSInteger index = [model.value integerValue];
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.dayArr selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 懒加载
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
        NSArray *arr = @[NSLocalizedString(@"Status", nil),
                         NSLocalizedString(@"Advance days to remind", nil),
                         NSLocalizedString(@"Remind minutes", nil),
                         NSLocalizedString(@"Menses duration", nil),
                         NSLocalizedString(@"Menstrual cycle", nil),
                         NSLocalizedString(@"Recent menstruation begin", nil),
                         NSLocalizedString(@"Days of finish since menses begin", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
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

- (NSMutableArray *)dayArr {
    if (!_dayArr) {
        _dayArr = @[].mutableCopy;
        for (NSInteger i = 1; i < 32; i++) {
            [_dayArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    return _dayArr;
}
@end
