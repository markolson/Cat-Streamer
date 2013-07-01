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
@synthesize loadingText, progress;

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
    
    [loadingText setHidden:NO];
    
    UILongPressGestureRecognizer *copytouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [copytouch setMinimumPressDuration:1.0];
    [[self view] addGestureRecognizer:copytouch];
    [[self view] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quickTap:)]];
}

-(void)setImageURL:(NSString *)url {
    imageURL = url;
    [self loadImage];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)quickTap:(UILongPressGestureRecognizer *)recognizer {
    if (imageView.isAnimating) {
        [imageView stopAnimating];
    } else {
        [imageView startAnimating];
    }
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
    [[UIPasteboard generalPasteboard] setData:imageData forPasteboardType:@"com.compuserve.gif" ];
}

-(void)loadImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.progress setHidden:NO];
        NSURL *url = [NSURL URLWithString:self.imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //NSLog(@"Grabbing %@", self.imageURL);
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setDownloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            float sofar = ((float)((int)totalBytesWritten) / (float)((int)totalBytesExpectedToWrite));
            if(sofar - [self.progress progress] > 0.03) {
                //NSLog(@"%lld/%lld = %f", totalBytesWritten, totalBytesExpectedToWrite, sofar);
                [self.progress setProgress:sofar animated:YES];
            }
            
        }];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *request, id data) {
            imageData = data;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageReady" object:imageView];
            [TestFlight passCheckpoint:@"gif_loaded"];
            [self.view setBackgroundColor:[UIColor blackColor]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [self.loadingText setText:@"THIS KITTEN BROKE D-:"];
            [self.progress setProgressTintColor:[UIColor redColor]];
            [self.progress setProgress:1];
            TFLog(@"GIFAIL on %@: %@", self.imageURL, error);
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
        [self.progress setHidden:YES];
        [self.progress setProgress:0 animated:NO];
        [loadingText setHidden:YES];
        [imageView setImage:[OLImage imageWithData:imageData] ];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
