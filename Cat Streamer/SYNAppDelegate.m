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
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[SYNViewController alloc] initWithNibName:@"SYNViewController_iPhone" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [TestFlight takeOff:@"8719a52f-2d62-4e0f-8762-b159b0526e5d"];
    return YES;
}

@end
