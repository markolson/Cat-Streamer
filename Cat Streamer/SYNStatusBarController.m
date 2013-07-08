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

@synthesize toolbar, favorite, share, progressbar, activeCat, activeController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:@"catChangedTo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:@"imageLoadStart" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"imagePercentDone" object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending) {
    }else{
        [toolbar setTranslucent:YES];
        [toolbar setBarStyle:UIBarStyleBlackOpaque];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)changeView:(NSNotification *)sender
{
    activeController = (SYNCatViewController *)[sender object];
    activeCat = activeController.cat;
    NSLog(@"Active is now %d (%d)", activeController.view.tag - 5000, activeController.isLoaded);
    if(activeController.isLoaded == NO) {
        NSLog(@"Showing bar for %d", activeController.view.tag - 5000);
        [progressbar setProgress:0];
        [progressbar setHidden:NO];
        [favorite setEnabled:NO];
        [self toggleFavorite];
    }else{
        [self loadComplete];
    }
}

-(void) loadComplete {
    [progressbar setHidden:YES];
    [favorite setEnabled:YES];
    [self toggleFavorite];
}

- (void)updateProgress:(NSNotification *)sender
{
    NSDictionary *d = (NSDictionary * )[sender object];
    SYNCatViewController *controller = [d objectForKey:@"controller"];
    NSNumber *f = [d objectForKey:@"percent"];
    if(controller.view.tag == activeController.view.tag)
    {
        if([f floatValue] <= [progressbar progress]) { return; }
        [progressbar setProgress:[f floatValue]];
        //NSLog(@"Updating Progress %f For %d [%d]", [f floatValue], activeController.view.tag - 5000, controller.view.tag);
        if([f floatValue] == 1.0) {
            NSLog(@"progress based load complete for %d", activeController.view.tag - 5000);
            [self loadComplete];
        }
    }

}



-(IBAction)launchFeedback {
    [TestFlight openFeedbackView];
}

-(void) favorited {
    [activeCat setFavorited:[NSNumber numberWithBool:!activeCat.favorited.boolValue]];
    UIView *sup = self.view.superview.superview;
     MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:sup animated:YES];
    [hud setAnimationType:MBProgressHUDAnimationZoom];
    [hud setMode:MBProgressHUDModeText];
    hud.labelText =  activeCat.favorited.boolValue ? @"Favorited" : @"Unfavorited";
    [TestFlight passCheckpoint:hud.labelText];
    [hud hide:YES afterDelay:0.5];
    [self toggleFavorite];
}

- (void)toggleFavorite {
    if(activeCat.favorited.boolValue == YES)
    {
        [favorite setStyle:UIBarButtonItemStyleDone];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending) {
            [favorite setTintColor:[UIColor magentaColor]];
        }
    }else{
        [favorite setStyle:UIBarButtonItemStyleBordered];
        [favorite setTintColor:nil];
    }
}

-(void) shared {}
@end
