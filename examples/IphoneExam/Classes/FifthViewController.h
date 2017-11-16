//
//  FirstViewController.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneExamAppDelegate.h"

@interface FifthViewController : UIViewController {
    IBOutlet id button;
    IBOutlet IphoneExamAppDelegate *delegate;
}

-(IBAction) showClick:(id)sender;

-(void) showCallback;

@end
