//
//  FCHistoryDataTableViewCell.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCHistoryDataTableViewCell.h"
#import <Masonry.h>
#import "FCDefinitions.h"
@interface FCHistoryDataTableViewCell ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *firstValueLabel;
@property (nonatomic, strong) UILabel *secondValueLabel;
@property (nonatomic, strong) UILabel *thirdValueLabel;
@property (nonatomic, strong) UILabel *fourthValueLabel;

@end

@implementation FCHistoryDataTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialzation];
    }
    
    return self;
}

- (void)initialzation {
    [self addSubViews];
    [self layout];
}

- (void)addSubViews {
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.firstValueLabel];
    [self.contentView addSubview:self.secondValueLabel];
    [self.contentView addSubview:self.thirdValueLabel];
    [self.contentView addSubview:self.fourthValueLabel];

}

- (void)layout {
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
        make.size.mas_equalTo(CGSizeMake(120, 20));
    }];
    [self.secondValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).offset(-5);
        make.size.mas_equalTo(CGSizeMake(140, 20));
    }];
    [self.firstValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.secondValueLabel.mas_left).offset(-20);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).offset(-5);
        make.size.mas_equalTo(CGSizeMake(140, 20));
    }];
    [self.fourthValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
        make.top.mas_equalTo(self.contentView.mas_centerY).offset(5);
        make.size.mas_equalTo(CGSizeMake(140, 20));
    }];
    [self.thirdValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.fourthValueLabel.mas_left).offset(-20);
        make.top.mas_equalTo(self.contentView.mas_centerY).offset(5);
        make.size.mas_equalTo(CGSizeMake(140, 20));
    }];
}

- (UILabel *)getCommenLabel {
    UILabel *label = [UILabel new];
    label.font = FONT_REGULAR(16);
    label.textColor = UIColorFromRGB(0x999999, 1.f);
    
    return label;
}

- (void)configStep:(FCCommenRecordModel *)model {
    self.timeLabel.text = [model.recordDate substringFromIndex:11];
    self.firstValueLabel.text = [NSString stringWithFormat:@"%@：%d %@", NSLocalizedString(@"Steps", nil), model.steps, NSLocalizedString(@"step", nil)];
    self.secondValueLabel.text = [NSString stringWithFormat:@"%@：%.2f kcal", NSLocalizedString(@"Calories", nil), model.calory/1000.f];
    self.thirdValueLabel.text = [NSString stringWithFormat:@"%@：%d m", NSLocalizedString(@"Distance", nil), model.distance/1000];
}
#pragma mark - 懒加载
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [self getCommenLabel];
        _timeLabel.font = FONT_REGULAR(18);
        _timeLabel.textColor = UIColorFromRGB(0x333333, 1.f);
    }
    
    return _timeLabel;
}
- (UILabel *)firstValueLabel {
    if (!_firstValueLabel) {
        _firstValueLabel = [self getCommenLabel];
    }
    
    return _firstValueLabel;
}

- (UILabel *)secondValueLabel {
    if (!_secondValueLabel) {
        _secondValueLabel = [self getCommenLabel];
    }
    
    return _secondValueLabel;
}

- (UILabel *)thirdValueLabel {
    if (!_thirdValueLabel) {
        _thirdValueLabel = [self getCommenLabel];
    }
    
    return _thirdValueLabel;
}

- (UILabel *)fourthValueLabel {
    if (!_fourthValueLabel) {
        _fourthValueLabel = [self getCommenLabel];
    }
    
    return _fourthValueLabel;
}

@end
