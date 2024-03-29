//
//  SYNStatusBar.h
//  Cat Streamer
//
//  Created by Mark Olson on 7/4/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAppDelegate.h"
#import "SYNCatViewController.h"
#import "MBProgressHUD.h"
#import "NSTimer+Blocks.h"

#import "OWActivities.h"

@interface SYNStatusBarController : UIViewController

@property UIToolbar IBOutlet *toolbar;
@property UIProgressView IBOutlet *progressbar;
@property UIBarButtonItem IBOutlet *favorite;
@property UIBarButtonItem IBOutlet *share;

@property (nonatomic, retain) NSTimer *hider;

@property (strong, nonatomic) SYNCatViewController *activeController;
@property (nonatomic, retain) Cat *activeCat;

-(IBAction) favorited;
-(IBAction) shared;
@end
