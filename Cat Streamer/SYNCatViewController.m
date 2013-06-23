//
//  SYNCatViewController.m
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "SYNCatViewController.h"
#import "SYNCatHerder.h"
#import "SYNRootViewController.h"
#import "AFNetworking.h"
#import "UIImage+animatedGIF.h"


@interface SYNCatViewController ()

@end

@implementation SYNCatViewController
@synthesize imageView, imageURL, imageData;
@synthesize loadingText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)imageReady:(NSNotification *)sender
{
    if([sender object] == imageView) {
        [loadingText setHidden:YES];
        [imageView setImage:[UIImage animatedImageWithAnimatedGIFData:imageData] ];
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"nyan-cat-white-background" ofType:@"gif"];  
    NSData *cat = [NSData dataWithContentsOfFile:filePath];
    [imageView setImage:[UIImage animatedImageWithAnimatedGIFData:cat] ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:@"imageReady" object:nil];
    
    [self loadImage];
    
    [loadingText setHidden:NO];
}

-(void)loadImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:self.imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSLog(@"%@", self.imageURL);
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *request, id data) {
            imageData = data;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageReady" object:imageView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
        [operation start];
        
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
