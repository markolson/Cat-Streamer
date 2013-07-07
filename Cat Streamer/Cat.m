//
//  Cat.m
//  Cat Streamer
//
//  Created by Mark Olson on 7/7/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import "Cat.h"


@implementation Cat

@dynamic url;
@dynamic seen;
@dynamic first_seen;
@dynamic favorited;
@dynamic date_favorited;

+(Cat *)findOrCreateByUrl:(NSString *)url {
    Cat *c = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Cat" inManagedObjectContext:UIAppDelegate.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setReturnsObjectsAsFaults:NO];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@", @"url", url];
    [request setPredicate:predicate];
    
    NSArray *array = [UIAppDelegate.managedObjectContext executeFetchRequest:request error:nil];
    if ([array count]) {
        c = [array objectAtIndex:0];
        [c setSeen:[NSNumber numberWithInt:[[c seen] intValue] + 1]];
    }else{
        c = [[Cat alloc] initWithEntity:entity insertIntoManagedObjectContext:UIAppDelegate.managedObjectContext];
        [c setUrl:url];
        [c setSeen:[NSNumber numberWithInt:1]];
        [c setFirst_seen:[NSDate date]];
    }
    NSError *error;
    [UIAppDelegate.managedObjectContext save:&error];
    NSLog(@"Cat %@ %@", c, error);
    
    return c;
}

@end