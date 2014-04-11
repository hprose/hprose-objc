//
//  Exam.h
//  IphoneExam
//
//  Created by Ma Bingyao on Apr 11, 2014.
//  Copyright hprose.com 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Exam

-(oneway void) hello:(NSString *)name selector:(SEL)selector delegate:(id)delegate;
-(oneway void) sum:(int)a and:(int)b selector:(SEL)selector delegate:(id)delegate;
-(oneway void) sum:(double)a and:(double)b and:(double)c selector:(SEL)selector delegate:(id)delegate;
-(oneway void) swapKeyAndValue:(byref NSDictionary *)dict selector:(SEL)selector delegate:(id)delegate;
-(oneway void) getUserList:(SEL)selector delegate:(id)delegate;
-(oneway void) thisMethodNotExist:(SEL)selector delegate:(id)delegate;

@end
