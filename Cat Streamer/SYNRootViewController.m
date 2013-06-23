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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    // create the cat herder, our UIPageViewControllerDataSource and assign it as the datasource
    // for the page controller
    self.herder = [[CatHerder alloc] init];
    self.pageViewController.dataSource = self.herder;
    
    SYNCatViewController *catViewController = [self.herder viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[catViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationOrientationHorizontal animated:NO completion:NULL];
    

    self.pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancePage:) name:@"pageViewAdvanceRequest" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
