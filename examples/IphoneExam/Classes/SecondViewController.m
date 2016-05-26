//
//  FirstViewController.m
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import "Exam.h"
#import "SecondViewController.h"


@implementation SecondViewController


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

-(IBAction) helloClick:(id)sender {

}

-(IBAction) sumIntClick:(id)sender {
/*
    [[delegate exam] sum:[[int_a text] intValue]
                     and:[[int_b text] intValue]
     selector:@selector(sumIntCallback:)
     delegate:self];
*/
    [[delegate client] invoke:@"sum" withArgs:@[
        @([[int_a text] intValue]),
        @([[int_b text] intValue])]
                     settings:@{@"block":^(id result, NSArray *args) {
        [int_sum setText:[result stringValue]];
    }}];
}

-(IBAction) sumDoubleClick:(id)sender {
    [[delegate exam] sum:[[double_a text] doubleValue]
                     and:[[double_b text] doubleValue]
                     and:[[double_c text] doubleValue]
     selector:@selector(sumDoubleCallback:)
     delegate:self];
/*
    [[delegate client] invoke:@"sum" withArgs:@[
        @([[double_a text] doubleValue]),
        @([[double_b text] doubleValue]),
        @([[double_c text] doubleValue])]
    block:^(id result, NSArray *args) {
        [double_sum setText:[result stringValue]];
    }];
 */
}

-(void) sumIntCallback:(int)result {
    [int_sum setText:[NSString stringWithFormat:@"%d", result]];
}

-(void) sumDoubleCallback:(double)result {
    [double_sum setText:[NSString stringWithFormat:@"%f", result]];
}

@end
