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
    BOOL _fetchingURLs;
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
    vc.imageURL = [images objectAtIndex:index];
    return vc;
}

-(void)fetchList:(NSInteger)count {
    if(_fetchingURLs) { return; }
    NSLog(@"loading more. %d", [images count]);
    NSString *url = [NSString stringWithFormat:@"http://catstreamer.herokuapp.com/cats.json"];
    _fetchingURLs = YES;
    
    for(int i = 0; i < count; i++) {
        AFJSONRequestOperation *tmpRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            // parse 'it
            NSLog(@"%@", [JSON valueForKey:@"catpic"]);
            [JSON valueForKey:@"catpic"] ? [self.images addObject:[JSON valueForKey:@"catpic"]] : nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageAvailable" object:self.images];
            // clear the block
            _fetchingURLs = NO;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            //
            NSLog(@"failed to download new url");
        }];
        [tmpRequest start];
    }
}
@end
