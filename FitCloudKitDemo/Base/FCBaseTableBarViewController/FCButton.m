//
//  FCButton.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "FCButton.h"
#import "FCDefinitions.h"

@implementation FCButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
        
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.superview.frame.size.height;
    if (width!=0 && height!=0) {
        self.titleLabel.frame = CGRectMake(0, height-18-kBottomOffset, width, 14);
        self.imageView.frame = CGRectMake(0, height-45-kBottomOffset, width, 27);
    }
}

#pragma mark - Setter & Getter
- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
