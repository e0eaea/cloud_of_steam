//
//  CardTableViewCell.h
//  IAM_IOS_ObjectiveC
//
//  Created by KMK on 2016. 5. 4..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "Video.h"

@interface CardTableViewCell : UITableViewCell

@property (nonatomic) BOOL is_photo;
@property (strong, nonatomic) Video *video;
@property (strong, nonatomic) Photo *photo;
@property (strong, nonatomic) IBOutlet UIImageView *card_image;
@property (strong, nonatomic) IBOutlet UITextField *card_title;
@property (strong, nonatomic) IBOutlet UIImageView *video_play;

- (void) set_cell;

@end
