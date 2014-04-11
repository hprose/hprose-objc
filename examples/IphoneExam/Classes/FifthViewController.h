//
//  FirstViewController.h
//  IphoneExam
//
//  Created by andot on 10-5-17.
//  Copyright hprfc 2010. All rights reserved.
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
