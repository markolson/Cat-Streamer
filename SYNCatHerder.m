//
//  CatHerder.m
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "SYNCatHerder.h"
#import "AFNetworking.h"
#import "SYNCatViewController.h"

@implementation CatHerder

@synthesize images, pageNumber;

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        self.images = [NSMutableArray array];
        
    }
    return self;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int t = pageNumber - 1;
    if (t == 0) { return nil; }
    return [self viewControllerAtIndex:t storyboard:viewController.storyboard];;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int t = pageNumber + 1;
    if(t >= [images count]) { return nil; }
    return [self viewControllerAtIndex:t storyboard:viewController.storyboard];;
}

- (SYNCatViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    NSLog(@"getting view for index %d", index);
    
    if([images count] <= index - 5) { [self fetchList:10]; }
    if([images count] < index) { index = 0; }
    
    SYNCatViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Cat"];
    vc.imageURL = [images objectAtIndex:index];
    NSLog(@"%@", vc);
    return vc;
}

-(void)fetchList:(NSInteger)count {
    NSLog(@"loading more.");
    [self.images addObjectsFromArray:@[@"http://catstreamer.herokuapp.com/images/anigif_enhanced-buzz-3054-1323296351-19.gif", @"http://catstreamer.herokuapp.com/images/cat_face_kick.gif", @"http://catstreamer.herokuapp.com/images/saIOc.jpg", @"http://catstreamer.herokuapp.com/images/SYccw.jpg.gif"]];
}
@end
