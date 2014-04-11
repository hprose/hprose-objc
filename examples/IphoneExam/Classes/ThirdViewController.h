//
//  FirstViewController.h
//  IphoneExam
//
//  Created by andot on 10-5-17.
//  Copyright hprfc 2010. All rights reserved.
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
