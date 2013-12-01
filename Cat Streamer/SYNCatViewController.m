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
@synthesize imageView, imageURL, imageData, shortCode;

@synthesize didAppear, loaded;

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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showActionBar" object:@{@"controller":self}];
    return;
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
	[UIPasteboard generalPasteboard].string = [self permalink];
}

- (NSString *)permalink {
    return [NSString stringWithFormat:@"http://cutestreamer.herokuapp.com/meow/%@", self.shortCode];
}

-(void)copyImagetoClipboard:(id)sender {
    [[UIPasteboard generalPasteboard] setData:imageData forPasteboardType:@"com.compuserve.gif" ];
}

-(bool)isLoaded {
    return loaded;
}

-(void)loadImage {
    if(!didAppear || !imageURL) { return; }
    if([imageData bytes] > 0) { return; }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        loaded = NO;
        float last_sofar = 0.0;

        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            float sofar = ((float)((int)totalBytesWritten) / (float)((int)totalBytesExpectedToWrite));
            if(sofar - last_sofar >= 0.05 || sofar > 0.99) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"imagePercentDone" object:@{@"controller":self, @"percent": [NSNumber numberWithFloat:sofar]}];
            }
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *request, id data) {
            shortCode = [[[request response] URL] lastPathComponent];
            imageURL = [self permalink];
            imageData = data;
            loaded = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageReady" object:self];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            TFLog(@"GIFAIL on %@", self.imageURL);
            loaded = YES;
            
        }];
        [operation start];
    });
}

- (void)imageReady:(NSNotification *)sender
{
    if([sender object] == self) {
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
