//
//  FirstViewController.m
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import "Exam.h"
#import "FourthViewController.h"


@implementation FourthViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction) getUserListClick:(id)sender {
    [[delegate exam] getUserList:@selector(getUserListCallback:)
       delegate:self];
}

-(void) getUserListCallback:(NSArray *)result {
    NSMutableString *s = [NSMutableString string];
    NSString *sexStrings[] = {@"Unknown", @"Male", @"Female", @"InterSex"};
    for (id user in result) {
        [s appendFormat:@"Name:%@, Age:%@, Married:%@\nBirthday:%@, Sex:%@\n\n",
         user[@"name"],
         user[@"age"],
         [user[@"married"] boolValue] ? @"Yes" : @"No",
         [[NSDateFormatter new] stringFromDate:user[@"birthday"]],
         sexStrings[[user[@"sex"] intValue]]];
    }
    [label setText:s];
}


@end
