//
//  CardTableViewCell.m
//  IAM_IOS_ObjectiveC
//
//  Created by KMK on 2016. 5. 4..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import "CardTableViewCell.h"
#import "Common_modules.h"
#import "AppDelegate.h"


@implementation CardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}


- (void) set_cell
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM월dd일 a h시mm분"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    if(_is_photo)
    {
        [_video_play setHidden:YES];
        [_card_image setImage:[UIImage imageWithData:_photo.thumnail_image]];
        [_card_title setText:[dateFormatter stringFromDate:_photo.due_date]];
        
    }
    else
    {
        [_video_play setHidden:NO];
        [_card_image setImage:[UIImage imageWithData:_video.thumnail_image]];
        [_card_title setText:[dateFormatter stringFromDate:_video.due_date]];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}




@end
