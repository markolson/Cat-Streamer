//
//  SYNViewController.h
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNCatHerder.h"
#import "SYNStatusBarController.h"


@interface SYNRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *box;
@property (strong, nonatomic) IBOutlet UIView *actions;

@property (strong, nonatomic) SYNStatusBarController *statusBarController;

@property (strong, nonatomic) CatHerder *herder;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *statusViews;

@end
