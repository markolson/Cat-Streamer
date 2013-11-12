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

@synthesize toolbar, favorite, share, progressbar, activeCat, activeController, hider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:@"catChangedTo" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"imagePercentDone" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadComplete) name:@"imageReady" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBar:) name:@"showActionBar" object:nil];
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

- (void)resetFrame {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [self toggleFavorite];
    CGRect tf = toolbar.frame;
    tf.origin.y = 8;
    toolbar.frame = tf;
    [UIView commitAnimations];
}

- (void) dropFrame {
    [self toggleFavorite];
    CGRect tf = toolbar.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    tf.origin.y = tf.size.height;
    toolbar.frame = tf;
    [UIView commitAnimations];
}

- (void)toggleBar:(NSNotification *)sender
{
    [self resetFrame];
    [hider invalidate];
    hider = [NSTimer timerWithTimeInterval:3 block:^(NSTimer *t){
        [self dropFrame];
    } repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:hider forMode:NSDefaultRunLoopMode];
}

- (void)changeView:(NSNotification *)sender
{
    [hider invalidate];
    activeController = (SYNCatViewController *)[sender object];
    if(activeController.isLoaded == NO) {
        [progressbar setProgress:0];
        [progressbar setHidden:NO];
        [self toggleFavorite];
        [self resetFrame];
    }else{
        [self loadComplete];
    }
}

-(void) loadComplete {
    activeCat = [Cat findOrCreateByUrl:activeController.imageURL];
    [progressbar setHidden:YES];
    [self dropFrame];
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
    }

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
    
    [favorite setEnabled:activeController.isLoaded];
    if(activeCat.favorited.boolValue == YES)
    {
        [favorite setStyle:UIBarButtonItemStyleDone];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending) {
            [favorite setTintColor:[UIColor whiteColor]];
        }
    }else{
        [favorite setStyle:UIBarButtonItemStyleBordered];
        [favorite setTintColor:nil];
    }
}

-(void) shared {}
@end
