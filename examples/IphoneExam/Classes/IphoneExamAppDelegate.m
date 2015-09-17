//
//  IphoneExamAppDelegate.m
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import "IphoneExamAppDelegate.h"
#import "Exam.h"
#import "LogFilter.h"

@implementation IphoneExamAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize exam;
@synthesize client;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    self.window.rootViewController = self.rootViewController;
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    client = [[HproseHttpClient alloc] init:@"http://www.hprose.com/example/index.php"];
    [client setDelegate:self];
    [client setOnError:@selector(errorHandler:withException:)];
    [client setFilter:[LogFilter new]];
    exam = [client useService:@protocol(Exam)];
    return YES;
}

-(void)errorHandler:(NSString *)name withException:(NSException *)e {
    UIAlertView *alert = nil;
    alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error on: %@", name]
                 message:[e description]
                delegate:self
       cancelButtonTitle:@"OK" 
       otherButtonTitles:nil];
    [alert show];
}

-(IBAction) didEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

@end

