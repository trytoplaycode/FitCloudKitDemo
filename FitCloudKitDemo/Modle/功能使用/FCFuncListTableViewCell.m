//
//  FCFuncListTableViewCell.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCFuncListTableViewCell.h"
#import "FCDefinitions.h"
#import <Masonry.h>

@interface FCFuncListTableViewCell ()

@end

@implementation FCFuncListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(20);
            make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
        }];
        [self.contentView addSubview:self.valueLabel];
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
        }];
        [self.contentView addSubview:self.switchs];
        [self.switchs mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.mas_equalTo(self.contentView);
        }];
        [self.contentView addSubview:self.selectImageView];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(28, 28));
        }];
        self.selectImageView.hidden = YES;
        self.switchs.hidden = YES;
        self.valueLabel.hidden = YES;
    }
    
    return self;
}

- (void)configCellStyle:(FCCellStyle)style {
    self.switchs.hidden = style != FCCellStyleSwitchs;
    self.valueLabel.hidden = style != FCCellStyleNormal;
    self.selectImageView.hidden = style != FCCellStyleSelect;
    self.accessoryType = style != FCCellStyleNormal ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    if (style == FCCellStyleNone) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.valueLabel.hidden = NO;
    }
}

#pragma mark - 懒加载
- (LocalizedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [LocalizedLabel new];
        _nameLabel.textColor = UIColorFromRGB(0x333333, 1.f);
        _nameLabel.font = FONT_MEDIUM(16);
    }
    
    return _nameLabel;
}

- (LocalizedLabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [LocalizedLabel new];
        _valueLabel.textColor = UIColorFromRGB(0x999999, 1.f);
        _valueLabel.font = FONT_REGULAR(14);
        _valueLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _valueLabel;
}

- (UISwitch *)switchs {
    if (!_switchs) {
        _switchs = [[UISwitch alloc] init];
    }
    
    return _switchs;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [UIImageView new];
        _selectImageView.image = IMAGENAME(@"unselected");
    }
    
    return _selectImageView;
}
@end
