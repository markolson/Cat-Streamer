//
//  SYNViewController.h
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNCatHerder.h"

@interface SYNRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) CatHerder *herder;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end
