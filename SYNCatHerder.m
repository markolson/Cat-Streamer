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
}

@end

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
    int t = (viewController.view.tag - TAGOFFSET) - 1;
    if (t < 0) { return nil; }
    return [self viewControllerAtIndex:t storyboard:viewController.storyboard];;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int t = (viewController.view.tag - TAGOFFSET) + 1;
    if(t >= [images count]) { return nil; }
    return [self viewControllerAtIndex:t storyboard:viewController.storyboard];;
}

- (SYNCatViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    NSLog(@"getting view for index %d", index);
    if([images count] <= index + 5) { [self fetchList:10]; }
    if([images count] <= index) { index = 0; }
    
    SYNCatViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Cat"];
    vc.view.tag = 5000 + index;
    if([images count] > 0) { vc.imageURL = [images objectAtIndex:index]; }
    return vc;
}

-(void)fetchList:(NSUInteger)count {
    if(_fetchingURLs > 0) { NSLog(@"skipping fetch"); return; }
    NSString *url = [NSString stringWithFormat:@"http://catstreamer.herokuapp.com/cats.json"];
    _fetchingURLs += 1;
    
    for(int i = 0; i < count; i++) {
        AFJSONRequestOperation *tmpRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"%@", [JSON valueForKey:@"catpic"]);
            [JSON valueForKey:@"catpic"] ? [self.images addObject:[JSON valueForKey:@"catpic"]] : nil;
            if([self.images count] == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"initialImageAvailable" object:self.images];
            }
            _fetchingURLs -= 1;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Uh-oh.");
            _fetchingURLs -= 1;
        }];
        [tmpRequest start];
    }
    
}
@end
