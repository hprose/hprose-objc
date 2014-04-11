//
//  IphoneExamAppDelegate.h
//  IphoneExam
//
//  Created by andot on 10-5-17.
//  Copyright hprfc 2010. All rights reserved.
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
