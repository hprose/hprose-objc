//
//  Exam.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hprose.h"

@protocol Exam

-(oneway Promise *) hello:(NSString *)name;
-(void) hello:(NSString *)name selector:(SEL)selector delegate:(id)delegate;
-(void) sum:(int)a and:(int)b selector:(SEL)selector delegate:(id)delegate;
-(void) sum:(double)a and:(double)b and:(double)c selector:(SEL)selector delegate:(id)delegate;
-(void) swapKeyAndValue:(byref NSDictionary *)dict selector:(SEL)selector delegate:(id)delegate;
-(void) getUserList:(SEL)selector delegate:(id)delegate;
-(void) thisMethodNotExist:(SEL)selector delegate:(id)delegate;
-(void) testErrorCallback:(SEL)selector delegate:(id)delegate error:(HproseErrorBlock)errorBlock;

@end
