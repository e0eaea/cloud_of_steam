//
//  MainViewController.m
//  mkcloud_ios
//
//  Created by KMK on 2016. 5. 9..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import "MainViewController.h"
#import "Common_modules.h"
#import "AppDelegate.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <AVKit/AVKit.h>
@import MediaPlayer;

@interface MainViewController ()<UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *time_label;
@property (strong, nonatomic) IBOutlet UIButton *date_select_button;
@property (strong, nonatomic) IBOutlet UIDatePicker *date_picker;
@property (strong, nonatomic) IBOutlet UIView *date_picker_view;
@property (strong, nonatomic) NSString* due_date;
@property (strong, nonatomic) NSString* image_name;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _due_date=@"";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)picture_modify_click:(id)sender {
    
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    
    imagePicker.delegate = (id)self;
    
    imagePicker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
    
}
- (IBAction)video_send_to_server:(id)sender {
    
    
    
}


- (IBAction)video_click:(id)sender {
   
    
   // KakaoTalkLinkObject *label= [KakaoTalkLinkObject createLabel:@"http://www.naver.com"];
   // [KOAppCall openKakaoTalkAppLink:@[label]];


   
    
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = (id)self;
    
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    // This code ensures only videos are shown to the end user
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    videoPicker.hidesBottomBarWhenPushed=YES;
    
    [self.tabBarController.tabBar setHidden:YES];
    
    [self presentViewController:videoPicker animated:YES completion:nil];


}


-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    if(image==NULL)
    {   NSLog(@"비디오");
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"VideoURL = %@", videoURL);
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(uploadVideo:json:) withObject:videoURL withObject:@""];
        
         [self dismissViewControllerAnimated:YES completion:nil];
        
        
        
        /*
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        NSLog(@"error==%@, Refimage==%@", error, refImg);
        
        UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
         */
        
       // [_video_image setBackgroundImage:FrameImage forState:UIControlStateNormal];
    }
    else
    {
    // Code here to work with media
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    NSURL *imageFileURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    _image_name=[NSString stringWithFormat:@"%@", imageFileURL];
    NSLog(@"경로는 %@",imageFileURL);
    [_imageview setImage:image];
   
     [self dismissViewControllerAnimated:YES completion:nil];
    }


    
}
    

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)transfer_to_server:(id)sender {
    
    if([_due_date isEqualToString:@""])
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"경고"
                                      message:@"만료기간을 설정해주세요!"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"확인"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        return;
                                        
                                    }];
        
        [alert addAction:yesButton];
        
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    
    
    NSArray *dictionKeys = @[@"id", @"date", @"image_name"];
    NSArray *dictionVals = @[@"KMK", _due_date,_image_name];
    NSDictionary *client_data = [NSDictionary dictionaryWithObjects:dictionVals forKeys:dictionKeys];
    
    
    NSString *userJsonData = [Common_modules transToJson:client_data];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(uploadImageLegacy:json:) withObject:_imageview.image withObject:userJsonData];
    
    NSLog(@"서버요청완료!!");
    
}
- (IBAction)date_button_tapped:(id)sender {
    
    
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             CGRect moveFrame= _date_picker_view.frame;
                             moveFrame.origin.y = self.view.frame.size.height-_date_picker_view.frame.size.height;
                             _date_picker_view.frame=moveFrame;
                         }
                         completion:^(BOOL finished){
                             
                         }];

    
}
- (IBAction)date_picker_done:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *strDate = [dateFormatter stringFromDate:_date_picker.date];
    _time_label.text = strDate;
    
     [dateFormatter setDateFormat:@"HH"];
    NSInteger hours=[[dateFormatter stringFromDate:_date_picker.date] integerValue];
     [dateFormatter setDateFormat:@"mm"];
    NSInteger minutes=[[dateFormatter stringFromDate:_date_picker.date] integerValue];
    
    _due_date=[self calculate_due_date:hours minutes:minutes];
    NSLog(@"만료시간 %@",_due_date);

    
    
}

- (NSString *) calculate_due_date:(NSInteger)hours minutes:(NSInteger)minutes
{
    
    NSString * d_date;

    NSCalendar *cal = [NSCalendar currentCalendar];
   
    
    NSDate * cal2=[cal dateByAddingUnit:NSCalendarUnitMinute value:minutes toDate:[NSDate date] options:NSCalendarMatchNextTime];
    
    cal2= [cal dateByAddingUnit:NSCalendarUnitHour value:hours toDate:cal2 options:NSCalendarMatchNextTime];
    

    
    NSTimeZone *krTimeZone =[NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:krTimeZone];
    
    d_date=[dateFormatter stringFromDate:cal2];
    
    
    return d_date;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
