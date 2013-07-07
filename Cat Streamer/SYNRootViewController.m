//
//  SYNViewController.m
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "SYNRootViewController.h"
#import "SYNCatViewController.h"

@interface SYNRootViewController ()

@end

@implementation SYNRootViewController

@synthesize box, actions, statusViews, statusBarController, currentCat;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusBarController = [[SYNStatusBarController alloc] init];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    // create the cat herder, our UIPageViewControllerDataSource and assign it as the datasource
    // for the page controller
    self.herder = [[CatHerder alloc] init];
    [self.herder fetchList:2];
    self.pageViewController.dataSource = self.herder;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancePage:) name:@"pageViewAdvanceRequest" object:nil];
    
    SYNCatViewController *catViewController = [self.herder viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[catViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    [self.pageViewController.view setFrame:[self.box bounds]];
    [self.box addSubview:self.pageViewController.view];
    [self.box bringSubviewToFront:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.actions addSubview:statusBarController.view];}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
