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


@interface SYNCatViewController ()
@end

@implementation SYNCatViewController
@synthesize imageView, imageURL, imageData;

@synthesize didAppear;

-(void)viewDidAppear:(BOOL)animated {
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    didAppear = true;
    [self loadImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    didAppear = false;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"nyan-cat-white-background" ofType:@"gif"];
    [imageView setImage:[OLImage imageWithContentsOfFile:filePath] ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:@"imageReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialStart:) name:@"initialImageAvailable" object:nil];
    
    UILongPressGestureRecognizer *copytouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [copytouch setMinimumPressDuration:1.0];
    [[self view] addGestureRecognizer:copytouch];
    
    [[self view] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quickTap:)]];
}

-(void)setImageURL:(NSString *)url {
    imageURL = url;
    [self loadImage];
}

- (void)quickTap:(UILongPressGestureRecognizer *)recognizer {
    if (imageView.isAnimating) {
        [imageView stopAnimating];
    } else {
        [imageView startAnimating];
    }
}
-(BOOL)canBecomeFirstResponder { return YES; }

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *copyImage = [[UIMenuItem alloc] initWithTitle:@"Copy Image" action:@selector(copyImagetoClipboard:)];
        UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"Copy Link" action:@selector(copyLinktoClipboard:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuItems:[NSArray arrayWithObjects:copyImage, copyLink, nil]];
		[menu setTargetRect:self.view.frame inView:self.view];
        [menu setMenuVisible:YES animated:YES];
	}
}

- (void)copyLinktoClipboard:(id)sender {
	[UIPasteboard generalPasteboard].string = self.imageURL;
}


-(void)copyImagetoClipboard:(id)sender {
    [[UIPasteboard generalPasteboard] setData:imageData forPasteboardType:@"com.compuserve.gif" ];
}

-(void)loadImage {
    if(!didAppear || !imageURL) { NSLog(@"Not loading yet."); return; }
    if([imageData bytes] > 0 ) { NSLog(@"Already loaded!"); return; }
    
    Cat *c = [Cat findOrCreateByUrl:imageURL];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"catAdopted" object:c];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imageLoadStart" object:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]]];
        [operation setDownloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            float sofar = ((float)((int)totalBytesWritten) / (float)((int)totalBytesExpectedToWrite));
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imagePercentDone" object:[NSNumber numberWithFloat:sofar]];
        }];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *request, id data) {
            imageData = data;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageReady" object:imageView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            TFLog(@"GIFAIL on %@: %@", self.imageURL, error);
        }];
        [operation start];
    });
}

- (void)initialStart:(NSNotification *)sender
{
    NSArray *i = (NSArray *)[sender object];
    [self setImageURL:[i objectAtIndex:(5000-self.view.tag)]];
}

- (void)imageReady:(NSNotification *)sender
{
    if([sender object] == imageView) {
        [TestFlight passCheckpoint:@"gif_loaded"];
        [self.view setBackgroundColor:[UIColor blackColor]];
        [imageView setImage:[OLImage imageWithData:imageData] ];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
