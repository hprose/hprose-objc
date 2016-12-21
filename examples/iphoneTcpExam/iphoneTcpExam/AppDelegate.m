//
//  AppDelegate.m
//  iphoneTcpExam
//
//  Created by 马秉尧 on 2016/12/21.
//  Copyright © 2016年 Hprose. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _client = [HproseSocketClient client:@"tcp://127.0.0.1:4321"];
    [_client invoke:@"hello" withArgs:@[@"world 1"] settings:@{@"block": ^(id result, NSArray *args) {
        NSLog(@"%@", result);
    }, @"errorBlock": ^(NSString *name, id e) {
        NSLog(@"%@", e);
    }}];
    [_client invoke:@"hello" withArgs:@[@"world 2"] settings:@{@"block": ^(id result, NSArray *args) {
        NSLog(@"%@", result);
    }, @"errorBlock": ^(NSString *name, id e) {
        NSLog(@"%@", e);
    }}];
    [_client invoke:@"hello" withArgs:@[@"world 3"] settings:@{@"block": ^(id result, NSArray *args) {
        NSLog(@"%@", result);
    }, @"errorBlock": ^(NSString *name, id e) {
        NSLog(@"%@", e);
    }}];
    [_client invoke:@"hello" withArgs:@[@"world 4"] settings:@{@"block": ^(id result, NSArray *args) {
        NSLog(@"%@", result);
    }, @"errorBlock": ^(NSString *name, id e) {
        NSLog(@"%@", e);
    }}];
    [_client invoke:@"hello" withArgs:@[@"world 5"] settings:@{@"block": ^(id result, NSArray *args) {
        NSLog(@"%@", result);
    }, @"errorBlock": ^(NSString *name, id e) {
        NSLog(@"%@", e);
    }}];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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


@end
