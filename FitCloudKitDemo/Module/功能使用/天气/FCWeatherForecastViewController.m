//
//  FCWeatherForecastViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/7.
//

#import "FCWeatherForecastViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import <BRPickerView.h>
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
@interface FCWeatherForecastViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *temperatureArr;
@property (nonatomic, strong) NSMutableArray *weatherArr;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) NSMutableArray *forestArr;

@end

static NSString *identifier = @"list";

@implementation FCWeatherForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Weather", nil)];
    [self initialization];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
}

- (WEATHERTYPE)getWeatherType {
    WEATHERTYPE type = WEATHERTYPE_UNKNOWN;
    FCCommenCellModel *model = self.dataArr[2];
    if ([model.value isEqualToString:self.weatherArr[0]]) {
        type = WEATHERTYPE_SUNNY;
    }else if ([model.value isEqualToString:self.weatherArr[1]]) {
        type = WEATHERTYPE_CLOUDY;
    }else if ([model.value isEqualToString:self.weatherArr[2]]) {
        type = WEATHERTYPE_OVERCAST;
    }else if ([model.value isEqualToString:self.weatherArr[3]]) {
        type = WEATHERTYPE_SHOWERS;
    }else if ([model.value isEqualToString:self.weatherArr[4]]) {
        type = WEATHERTYPE_THUNDERSHOWERSWITHHAIL;
    }else if ([model.value isEqualToString:self.weatherArr[5]]) {
        type = WEATHERTYPE_LIGHTRAIN;
    }else if ([model.value isEqualToString:self.weatherArr[6]]) {
        type = WEATHERTYPE_MHSRAIN;
    }else if ([model.value isEqualToString:self.weatherArr[7]]) {
        type = WEATHERTYPE_SLEET;
    }else if ([model.value isEqualToString:self.weatherArr[8]]) {
        type = WEATHERTYPE_LIGHTSNOW;
    }else if ([model.value isEqualToString:self.weatherArr[9]]) {
        type = WEATHERTYPE_HEAVYSNOW;
    }else if ([model.value isEqualToString:self.weatherArr[10]]) {
        type = WEATHERTYPE_SANDSTORM;
    }else if ([model.value isEqualToString:self.weatherArr[11]]) {
        type = WEATHERTYPE_FOGORHAZE;
    }
    
    return type;
}

- (void)sureAction {
    FitCloudWeatherForecast *weather = [FitCloudWeatherForecast new];
    FCCommenCellModel *minTempModel = self.dataArr[0];
    weather.min = [minTempModel.value integerValue];
    FCCommenCellModel *maxTempModel = self.dataArr[1];
    weather.max = [maxTempModel.value integerValue];
    weather.weathertype = [self getWeatherType];
    [self.arr addObject:weather];
    if (self.refreshCallback) {
        self.refreshCallback();
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.temperatureArr selectIndex:100 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 1:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.temperatureArr selectIndex:100 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 2:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.weatherArr selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
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
        NSArray *arr = @[NSLocalizedString(@"Minimum Temperature", nil),
                         NSLocalizedString(@"Maximum Temperature", nil),
                         NSLocalizedString(@"Weather", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}

- (NSMutableArray *)temperatureArr {
    if (!_temperatureArr) {
        _temperatureArr = @[].mutableCopy;
        for (NSInteger i = -100; i < 100; i++) {
            [_temperatureArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    return _temperatureArr;
}

- (NSMutableArray *)weatherArr {
    if (!_weatherArr) {
        _weatherArr = @[NSLocalizedString(@"Sunny", nil),NSLocalizedString(@"Cloudy", nil),NSLocalizedString(@"OverCast", nil),NSLocalizedString(@"Showers", nil),NSLocalizedString(@"ThunderShowersWithHail", nil),NSLocalizedString(@"LightRain", nil),NSLocalizedString(@"MHSRain", nil),NSLocalizedString(@"Sleet", nil),NSLocalizedString(@"LightSnow", nil),NSLocalizedString(@"HeavySnow", nil),NSLocalizedString(@"SANDSTORM", nil),NSLocalizedString(@"FOGORHAZE", nil),NSLocalizedString(@"UNKNOWN", nil)].mutableCopy;
    }
    
    return _weatherArr;
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

