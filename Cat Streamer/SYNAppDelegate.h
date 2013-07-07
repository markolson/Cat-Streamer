//
//  SYNAppDelegate.h
//  Cat Streamer
//
//  Created by Mark Olson on 6/23/13.
//  Copyright (c) 2013 Mark Olson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cat.h"

@class SYNViewController;

@interface SYNAppDelegate : UIResponder <UIApplicationDelegate>



@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SYNViewController *viewController;

//Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

#define UIAppDelegate \
((SYNAppDelegate *)[UIApplication sharedApplication].delegate)
@end
