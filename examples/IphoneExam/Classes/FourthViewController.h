//
//  FirstViewController.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneExamAppDelegate.h"

@interface FourthViewController : UIViewController {
    IBOutlet id button;
    IBOutlet id label;
    IBOutlet IphoneExamAppDelegate *delegate;
}

-(IBAction) getUserListClick:(id)sender;

-(void) getUserListCallback:(NSArray *)result;

@end
