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
    if([images count] <= index + 5) {
        [self fetchList:10];
    }
    if([images count] <= index) { index = 0; }
    
    SYNCatViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Cat"];
    vc.view.tag = 5000 + index;
    if([images count] > 0) { vc.imageURL = [images objectAtIndex:index]; }
    return vc;
}

-(void)fetchList:(NSUInteger)count {
    if(_fetchingURLs > 0) { return; }
    NSString *url = [NSString stringWithFormat:@"http://cutestreamer.herokuapp.com/multi"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
    _fetchingURLs += 1;
    
    AFJSONRequestOperation *tmpRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        for(NSDictionary *d in JSON) {
            [JSON valueForKey:@"catpic"] ? [self.images addObject:[d valueForKey:@"catpic"]] : nil;
            if([self.images count] == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"initialImageAvailable" object:self.images];
            }
            
        }
        _fetchingURLs -= 1;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchListFailure" object:self.images];
        TFLog(@"Failed to reach server oh goooddddd");
        _fetchingURLs -= 1;
    }];
    [tmpRequest start];
    
}
@end
