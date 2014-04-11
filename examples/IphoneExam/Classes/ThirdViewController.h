//
//  FirstViewController.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneExamAppDelegate.h"

@interface ThirdViewController : UIViewController {
    IBOutlet id button;
    IBOutlet id label;
    IBOutlet IphoneExamAppDelegate *delegate;
}

-(IBAction) swapClick:(id)sender;

-(void) swapCallback:(NSDictionary *)result withArgs:(NSArray *)args;

@end
