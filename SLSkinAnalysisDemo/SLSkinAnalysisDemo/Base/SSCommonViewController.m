//
//  SSCommonViewController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSCommonViewController.h"

@interface SSCommonViewController ()

@end

@implementation SSCommonViewController

- (void)handleBackEvent:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.navigationController.qmui_rootViewController && self.navigationController.qmui_rootViewController != self) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem qmui_backItemWithTarget:self action:@selector(handleBackEvent:)];
    }
}

#pragma mark - delegate

- (nullable UIColor *)navigationBarTintColor
{
    return [UIColor whiteColor];
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

- (BOOL)preferredNavigationBarHidden
{
    return NO;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable
{
    return YES;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view
{
    return YES;
}

- (BOOL)forceEnableInteractivePopGestureRecognizer
{
    return YES;
}
@end
