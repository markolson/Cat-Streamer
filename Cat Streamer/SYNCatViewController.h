//
//  SYNCatViewController.h
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLImageView.h"
#import "OLImage.h"

@interface SYNCatViewController : UIViewController

@property (strong, nonatomic) IBOutlet OLImageView *imageView;

@property (nonatomic) bool didAppear;
@property (nonatomic) bool loaded;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *imageURL;

-(bool)isLoaded;
@end


#import "SYNStatusBarController.h"