//
//  Cat.h
//  Cat Streamer
//
//  Created by Mark Olson on 7/7/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SYNAppDelegate.h"

@interface Cat : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) NSDate * first_seen;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSDate * date_favorited;

+(Cat *)findOrCreateByUrl:(NSString *)url;

@end
