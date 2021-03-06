//
//  AppDelegate.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "AppDelegate.h"
#import "MIHelpTool.h"
#import "MIPhotographyViewController.h"
#import "MIThirdPartyLoginManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //设置状态栏白色模式
    application.statusBarStyle = UIStatusBarStyleLightContent;

    //延迟加载
    [NSThread sleepForTimeInterval:1.0];

    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[MIHelpTool assetsPath]]) {
        
        [MIHelpTool createAssetsPath];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// iOS9 以上用这个方法接收
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {

    if (@available(iOS 9.0, *)) {
        if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.sina.weibo"]) {
            return [WeiboSDK handleOpenURL:url delegate:[MIThirdPartyLoginManager shareManager]];
        } else if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.xin"]) {
            return [WXApi handleOpenURL:url delegate:[MIThirdPartyLoginManager shareManager]];
        } else if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.mqq"]) {
            return [TencentOAuth HandleOpenURL:url];
        }
    } else {
        // Fallback on earlier versions
    }
    
    return YES;
}

// iOS9 以下用这个方法接收
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [WeiboSDK handleOpenURL:url delegate:[MIThirdPartyLoginManager shareManager]];
    } else if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:[MIThirdPartyLoginManager shareManager]];
    } else if ([sourceApplication isEqualToString:@"com.tencent.mqq"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return YES;
}

@end
