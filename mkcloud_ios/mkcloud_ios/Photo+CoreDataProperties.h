//
//  Photo+CoreDataProperties.h
//  mkcloud_ios
//
//  Created by KMK on 2016. 6. 11..
//  Copyright © 2016년 KMK. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *due_date;
@property (nullable, nonatomic, retain) NSString *server_url;
@property (nullable, nonatomic, retain) NSString *my_url;
@property (nullable, nonatomic, retain) NSData *thumnail_image;
@property (nullable, nonatomic, retain) My_Info *my_info;

@end

NS_ASSUME_NONNULL_END
