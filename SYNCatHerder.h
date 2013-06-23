//
//  CatHerder.h
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNCatViewController;


@interface CatHerder : NSObject <UIPageViewControllerDataSource>

- (SYNCatViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;

@property (strong, nonatomic) NSMutableArray *images;
@property NSUInteger pageNumber;
@end
