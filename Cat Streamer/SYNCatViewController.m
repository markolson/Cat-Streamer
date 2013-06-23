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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"nyan-cat-white-background" ofType:@"gif"];  
    NSData *cat = [NSData dataWithContentsOfFile:filePath];
    [imageView setImage:[UIImage animatedImageWithAnimatedGIFData:cat] ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:@"imageReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialStart:) name:@"initialImageAvailable" object:nil];
    
    [self loadImage];
    
    [loadingText setHidden:NO];
    
    UILongPressGestureRecognizer *copytouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [copytouch setMinimumPressDuration:1.0];
    [[self view] addGestureRecognizer:copytouch];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *copyImage = [[UIMenuItem alloc] initWithTitle:@"Copy Image" action:@selector(copyImagetoClipboard:)];
        UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"Copy Link" action:@selector(copyLinktoClipboard:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuItems:[NSArray arrayWithObjects:copyImage, copyLink, nil]];
		[menu setTargetRect:imageView.frame inView:imageView];
        [menu setMenuVisible:YES animated:YES];
	}
}

- (void)copyLinktoClipboard:(id)sender {
	[UIPasteboard generalPasteboard].string = self.imageURL;
}


-(void)copyImagetoClipboard:(id)sender {
    [UIPasteboard generalPasteboard].image = imageView.image;
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

- (void)initialStart:(NSNotification *)sender
{
    NSArray *i = (NSArray *)[sender object];
    if([i count] == 1) {
        [self setImageURL:[i objectAtIndex:0]];
        [self loadImage];
    }
}

- (void)imageReady:(NSNotification *)sender
{
    if([sender object] == imageView) {
        [loadingText setHidden:YES];
        [imageView setImage:[UIImage animatedImageWithAnimatedGIFData:imageData] ];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
