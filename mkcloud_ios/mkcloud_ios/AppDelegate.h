//
//  AppDelegate.h
//  mkcloud_ios
//
//  Created by KMK on 2016. 5. 9..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "My_Info.h"
#import "Size_Define.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)connectToServer:(NSString*)jsonString url:(NSString *)urlString;

- (My_Info *)getMyInfo;
- (void) saveData:(NSDictionary *)data ;



@end

