//
//  IphoneExamAppDelegate.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hprose.h"

@interface IphoneExamAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *__weak tabBarController;
    HproseHttpClient *client;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (weak, nonatomic, readonly) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet HproseHttpClient *client;

-(IBAction) didEndOnExit:(id)sender;

@end
