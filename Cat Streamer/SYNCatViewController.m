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
	[UIPasteboard generalPasteboard].string = self.imageURL;
}


-(void)copyImagetoClipboard:(id)sender {
    [[UIPasteboard generalPasteboard] setData:imageData forPasteboardType:@"com.compuserve.gif" ];
}

-(bool)isLoaded {
    return loaded;
}

-(void)loadImage {
    if(!didAppear || !imageURL) { NSLog(@"Not loading yet."); return; }
    if([imageData bytes] > 0) { NSLog(@"Already load{ed,ing}!"); return; }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Starting! %@", imageURL);
        loaded = NO;
        float last_sofar = 0.0;
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]]];
        [operation setDownloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            float sofar = ((float)((int)totalBytesWritten) / (float)((int)totalBytesExpectedToWrite));
            if(sofar - last_sofar >= 0.05 || sofar > 0.99) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"imagePercentDone" object:@{@"controller":self, @"percent": [NSNumber numberWithFloat:sofar]}];
            }
        }];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *request, id data) {
            imageURL = [[[request response] URL] absoluteString];
            NSLog(@"DONE! %@",[imageURL lastPathComponent]);
            imageData = data;
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
        loaded = YES;
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
