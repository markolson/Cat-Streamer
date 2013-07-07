//
//  SYNStatusBar.m
//  Cat Streamer
//
//  Created by Mark Olson on 7/4/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "SYNStatusBarController.h"

@interface SYNStatusBarController ()

@end

@implementation SYNStatusBarController

@synthesize toolbar, add, share, progressbar, db;

- (void)viewDidLoad
{
    db = UIAppDelegate.managedObjectContext;
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showToolbar:) name:@"imageReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProgressbar:) name:@"imageLoadStart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"imagePercentDone" object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending) {
        //running on iOS 7 or higher
        
    }else{
        [toolbar setTranslucent:YES];
        [toolbar setBarStyle:UIBarStyleBlackOpaque];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showToolbar:(NSNotification *)sender
{
    [progressbar setHidden:YES];
}

- (void)showProgressbar:(NSNotification *)sender
{
    [progressbar setProgress:0];
    [progressbar setHidden:NO];
}

- (void)updateProgress:(NSNotification *)sender
{
    NSNumber *f = [sender object];
    [progressbar setProgress:[f floatValue]];
}

-(IBAction)launchFeedback {
    [TestFlight openFeedbackView];
}

-(void) added { }

-(void) shared {}
@end
