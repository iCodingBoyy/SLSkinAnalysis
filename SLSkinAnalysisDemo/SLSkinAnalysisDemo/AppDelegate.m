//
//  AppDelegate.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/17.
//

#import "AppDelegate.h"
#import "SSNavigationController.h"
#import "SSRootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    SSRootViewController *rootViewController = [[SSRootViewController alloc]init];
    SSNavigationController *navigationController = [[SSNavigationController alloc]initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
