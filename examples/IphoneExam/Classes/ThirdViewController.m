//
//  FirstViewController.m
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import "Exam.h"
#import "ThirdViewController.h"


@implementation ThirdViewController


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

-(IBAction) swapClick:(id)sender {
    id<Exam> exam = [[delegate client] useService:@protocol(Exam)];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    dict[@"Jan"] = @"January";
    dict[@"Feb"] = @"February";
    dict[@"Mar"] = @"March";
    dict[@"Apr"] = @"April";
    [label setText:[dict description]];
    [exam swapKeyAndValue:dict selector:@selector(swapCallback:withArgs:) delegate:self];
}

-(void) swapCallback:(NSDictionary *)result withArgs:(NSArray *)args {
    NSDictionary *dict = args[0];
    [label setText:[NSString stringWithFormat:@"before invke:%@\nafter invoke:%@",
                    [label text],
                    [dict description]]];
}


@end
