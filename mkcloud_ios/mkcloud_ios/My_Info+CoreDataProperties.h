//
//  My_Info+CoreDataProperties.h
//  mkcloud_ios
//
//  Created by KMK on 2016. 6. 11..
//  Copyright © 2016년 KMK. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "My_Info.h"

NS_ASSUME_NONNULL_BEGIN

@interface My_Info (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSSet<Photo *> *my_photo;
@property (nullable, nonatomic, retain) NSSet<Video *> *my_video;

@end

@interface My_Info (CoreDataGeneratedAccessors)

- (void)addMy_photoObject:(Photo *)value;
- (void)removeMy_photoObject:(Photo *)value;
- (void)addMy_photo:(NSSet<Photo *> *)values;
- (void)removeMy_photo:(NSSet<Photo *> *)values;

- (void)addMy_videoObject:(Video *)value;
- (void)removeMy_videoObject:(Video *)value;
- (void)addMy_video:(NSSet<Video *> *)values;
- (void)removeMy_video:(NSSet<Video *> *)values;

@end

NS_ASSUME_NONNULL_END
