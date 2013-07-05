//
//  SYNStatusBar.h
//  Cat Streamer
//
//  Created by Mark Olson on 7/4/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNStatusBarController : UIViewController

@property UIToolbar IBOutlet *toolbar;

@property UIProgressView IBOutlet *progressbar;

@property UIBarButtonItem IBOutlet *add;
@property UIBarButtonItem IBOutlet *share;

-(IBAction) added;
-(IBAction) shared;
@end