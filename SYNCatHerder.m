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

#define TAGOFFSET 5000

@interface CatHerder() {
    int _fetchingURLs;
    int relativeOffset;
    NSMutableDictionary *catz;
}

@end

@implementation CatHerder

@synthesize images, pageNumber;

- (id)init
{
    catz = [[NSMutableDictionary alloc] initWithCapacity:10];
    self = [super init];
    if (self) {
        // Create the data model.
        self.images = [NSMutableArray array];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:@"imageReady" object:nil];
    return self;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int t = (viewController.view.tag - TAGOFFSET) - 1;
    if (t < 0) { return nil; }
    return [self viewControllerAtIndex:t storyboard:viewController.storyboard];;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int t = (viewController.view.tag - TAGOFFSET) + 1;
    return [self viewControllerAtIndex:t storyboard:viewController.storyboard];;
}

- (SYNCatViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    SYNCatViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Cat"];
    vc.view.tag = TAGOFFSET + index;
    NSNumber *n = [NSNumber numberWithInt:(vc.view.tag - TAGOFFSET)];
    if ([[catz allKeys] containsObject:n]) {
        NSLog(@"Setting %d's imageURL to %@.", index, [catz objectForKey:n]);
        vc.imageURL = [NSString stringWithFormat:@"http://localhost:8080/meow/%@", [catz objectForKey:n]];
    }else{
        NSLog(@"Setting %d's imageURL to meow.", index);
        vc.imageURL = @"http://localhost:8080/meow";
    }
    return vc;
}

- (void)imageReady:(NSNotification *)sender
{
    SYNCatViewController *c = (SYNCatViewController *)[sender object];
    [catz setObject:[[NSURL URLWithString:c.imageURL] lastPathComponent] forKey:[NSNumber numberWithInt:(c.view.tag - TAGOFFSET)]];
}
@end
