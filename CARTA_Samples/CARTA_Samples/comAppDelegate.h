//
//  comAppDelegate.h
//  CARTA_Samples
//
//  Created by Taylor McDonald on 9/11/13.
//  Copyright (c) 2013 secondsite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface comAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
