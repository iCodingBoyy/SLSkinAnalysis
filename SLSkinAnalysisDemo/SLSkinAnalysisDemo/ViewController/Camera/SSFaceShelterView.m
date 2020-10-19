//
//  SSFaceShelterView.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/27.
//

#import "SSFaceShelterView.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>


@implementation SSFaceShelterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeZero;
    
    CGSize regionSize = self.regionLabel.intrinsicContentSize;
    CGSize nameSize = self.shelterNameLabel.intrinsicContentSize;
    size.width = MAX(regionSize.width, nameSize.width);
    size.height = regionSize.height + nameSize.height + 5;
    return size;
}

- (void)setUp
{
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = YES;
    
    _regionLabel = [[UILabel alloc]init];
    _regionLabel.font = [UIFont systemFontOfSize:13];
    _regionLabel.textColor = [UIColor qmui_colorWithHexString:@"#FFFFFF"];
    _regionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_regionLabel];
    [self.regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_centerY).offset(-2.5);
    }];
    
    _shelterNameLabel = [[UILabel alloc]init];
    _shelterNameLabel.font = [UIFont systemFontOfSize:15];
    _shelterNameLabel.textColor = [UIColor qmui_colorWithHexString:@"#FF4275"];
    _shelterNameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_shelterNameLabel];
    [self.shelterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_centerY).offset(2.5);
    }];
}

@end
