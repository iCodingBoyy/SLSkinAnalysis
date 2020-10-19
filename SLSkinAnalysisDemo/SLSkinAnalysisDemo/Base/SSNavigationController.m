//
//  SSNavigationController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSNavigationController.h"

@interface SSNavigationController ()

@end

@implementation SSNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    QMUICMI.tableViewCellCheckmarkImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(15, 12) tintColor:[UIColor orangeColor]];
}

- (UIImage*)navigationBarBackgroundImage
{
    UIColor *color = [UIColor qmui_colorWithHexString:@"#FF4275"];
    CGSize size = CGSizeMake(SCREEN_WIDTH, 88);
    UIImage *image = [UIImage qmui_imageWithColor:color size:size cornerRadius:0];
    return image;
}

- (UIImage*)navigationBarShadowImage
{
    UIColor *color = [UIColor qmui_colorWithHexString:@"#FF4275"];
    CGSize size = CGSizeMake(SCREEN_WIDTH, 0.5);
    UIImage *image = [UIImage qmui_imageWithColor:color size:size cornerRadius:0];
    return image;
}

- (nullable UIColor *)navigationBarTintColor
{
    return [UIColor whiteColor];
}

- (BOOL)preferredNavigationBarHidden
{
    return YES;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable
{
    return YES;
}

@end
