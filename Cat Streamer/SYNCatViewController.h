//
//  SYNCatViewController.h
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNCatViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *imageURL;

@end
