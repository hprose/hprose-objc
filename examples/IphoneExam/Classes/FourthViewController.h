//
//  FirstViewController.h
//  IphoneExam
//
//  Created by andot on 10-5-17.
//  Copyright hprfc 2010. All rights reserved.
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
