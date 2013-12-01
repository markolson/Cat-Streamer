//
//  SYNViewController.m
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "SYNRootViewController.h"
#import "SYNCatViewController.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface SYNRootViewController () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, retain) NSTimer *adHider;

@end

@implementation SYNRootViewController

@synthesize box, actions, statusViews, statusBarController, currentCat, adHider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.statusBarController = [[SYNStatusBarController alloc] init];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    // create the cat herder, our UIPageViewControllerDataSource and assign it as the datasource
    // for the page controller
    self.herder = [[CatHerder alloc] init];
    self.pageViewController.dataSource = self.herder;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancePage:) name:@"pageViewAdvanceRequest" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(maybeShowAd) name:@"imageReady" object:nil];
    
    SYNCatViewController *catViewController = [self.herder viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[catViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    [self.pageViewController.view setFrame:[self.box bounds]];
    [self.box addSubview:self.pageViewController.view];
    [self.box bringSubviewToFront:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.actions addSubview:statusBarController.view];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"catChangedTo" object:((SYNCatViewController *)self.pageViewController.viewControllers[0])];
    
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(completed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"catChangedTo" object:((SYNCatViewController *)pageViewController.viewControllers[0])];
    }
}

#pragma section iAd

- (void)maybeShowAd {
    [self hideAd:YES];
    if((int)(random() % 10) == 3) {
        [self showAd];
    }
}

- (void)viewDidLayoutSubviews
{
    [self layoutAnimated:[UIView areAnimationsEnabled]];
}

- (void)layoutAnimated:(BOOL)animated
{
    CGRect bannerFrame = _bannerView.frame;
    CGSize sizeForBanner = [_bannerView sizeThatFits:box.frame.size];
    if (_bannerView.bannerLoaded) {
        bannerFrame.size.height = sizeForBanner.height;
        bannerFrame.size.width = sizeForBanner.width;
        _bannerView.frame = bannerFrame;
    }
}

- (void)showAd {
    if(![_bannerView isBannerLoaded]) {
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            [TestFlight passCheckpoint:@"$$$"];
            
            CGRect bannerFrame = CGRectZero;
            bannerFrame.size = [_bannerView sizeThatFits:box.frame.size];
            bannerFrame.origin.y = 0;
            _bannerView.frame = bannerFrame;
            _bannerView.alpha = 1;
            
            CGRect boxFrame = box.frame;
            boxFrame.origin.y += (bannerFrame.size.height/3);
            box.frame = boxFrame;
        }];
        
        [adHider invalidate];
        adHider = [NSTimer timerWithTimeInterval:10 block:^(NSTimer *t){
            [self hideAd:YES];
        } repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:adHider forMode:NSDefaultRunLoopMode];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //if([_bannerView isBannerLoaded]) { NSLog(@"double loaded?"); return; }
    NSLog(@"done loading.");
    //[self showAd];
}

- (void) hideAd:(BOOL)animated {
    if(![_bannerView isDescendantOfView:self.view])
    {
        NSLog(@"allocing new banner");
        _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        _bannerView.delegate = self;
        _bannerView.alpha = 0;
        [self.view addSubview:_bannerView];
    }
    
    [UIView animateWithDuration:(animated == YES) ? 1 : 0 animations:^{
        [adHider invalidate];
        
        CGRect boxFrame = box.frame;
        boxFrame.origin.y = 0;
        box.frame = boxFrame;
        
        CGRect bannerFrame = _bannerView.frame;
        bannerFrame.origin.y = 0 - bannerFrame.size.height;
        _bannerView.frame = bannerFrame;
        _bannerView.alpha = 0;
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    TFLog(@"didFailToReceiveAdWithError %@", error);
    [_bannerView removeFromSuperview];
    [self hideAd:NO];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [TestFlight passCheckpoint:@"$$$!!!!!!"];
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
