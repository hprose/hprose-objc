//
//  FirstViewController.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneExamAppDelegate.h"

@interface FirstViewController : UIViewController {
    IBOutlet id button;
    IBOutlet id button2;
    IBOutlet id text;
    IBOutlet id label;
    IBOutlet IphoneExamAppDelegate *delegate;
}

-(IBAction) helloClick:(id)sender;

-(IBAction) hello2Click:(id)sender;

-(void) helloCallback:(NSString *)result;

@end
