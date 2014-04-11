//
//  FirstViewController.h
//  IphoneExam
//
//  Created by andot on 10-5-17.
//  Copyright hprfc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneExamAppDelegate.h"

@interface FirstViewController : UIViewController {
    IBOutlet id button;
    IBOutlet id text;
    IBOutlet id label;
    IBOutlet IphoneExamAppDelegate *delegate;
}

-(IBAction) helloClick:(id)sender;

-(void) helloCallback:(NSString *)result;

@end
