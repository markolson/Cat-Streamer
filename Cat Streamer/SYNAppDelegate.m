//
//  SYNAppDelegate.m
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "SYNAppDelegate.h"

#import "SYNRootViewController.h"

@implementation SYNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight setDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [TestFlight takeOff:@"8719a52f-2d62-4e0f-8762-b159b0526e5d"];
    return YES;
}

@end
