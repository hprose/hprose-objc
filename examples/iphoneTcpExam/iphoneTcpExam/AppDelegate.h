//
//  AppDelegate.h
//  iphoneTcpExam
//
//  Created by 马秉尧 on 2016/12/21.
//  Copyright © 2016年 Hprose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hprose.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) HproseClient *client;

@end

