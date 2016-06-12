//
//  VideoViewController.m
//  mkcloud_ios
//
//  Created by KMK on 2016. 6. 11..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import "VideoViewController.h"
#import "My_Info.h"
#import "Video.h"
#import "CardTableViewCell.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "AppDelegate.h"
#import "AFNetworking.h"



@interface VideoViewController () <UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic) IBOutlet UITableView * tableview;
@property (nonatomic) IBOutlet UIView * showview;
@property (nonatomic)  NSMutableArray * tableData;
@property (strong, nonatomic) IBOutlet UIDatePicker *date_picker;
@property (strong, nonatomic) IBOutlet UIView *date_picker_view;
@property (strong, nonatomic) IBOutlet UIImageView *image_preview;
@property (strong, nonatomic) IBOutlet UIProgressView *progress_view;
@property (strong, nonatomic) My_Info* myInfo;
@property (strong, nonatomic) Video* video;
@property (strong, nonatomic) IBOutlet UIButton *done_to_server;

@property (strong, nonatomic) IBOutlet UILabel *delete_label;

@end

@implementation VideoViewController
{
    
    NSString * current_url;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reload_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)reload_list
{
    _tableData=[NSMutableArray new];
    
    _managedObjectContext = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"My_Info" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSManagedObject *info= [fetchedObjects objectAtIndex:0];
    
    
    _myInfo = (My_Info *)info;
    
    
    NSSortDescriptor *due = [NSSortDescriptor sortDescriptorWithKey:@"due_date" ascending:YES];
    NSArray *sorted_arr = [_myInfo.my_video sortedArrayUsingDescriptors:@[due]];
    
    [_tableData addObjectsFromArray:sorted_arr];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


//섹션의 row갯수 반환
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"현재 셀의 갯수 %lu",(unsigned long)_tableData.count);
    return _tableData.count;
}


// 셀 만들기
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CardTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CardTableViewCell" owner:self options:nil]
                               objectAtIndex:0];
   Video *video=[_tableData objectAtIndex:indexPath.row];
    cell.is_photo=NO;
    cell.video=video;
    
    
    [cell set_cell];
    return cell;
    
}


//섹션 헤더 높이
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UIColor *clearColor = [UIColor clearColor];
    view.tintColor = clearColor;
}

//테이블셀의 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"셀클릭");
    [UIView setAnimationsEnabled:YES];
 
    Video *video=[_tableData objectAtIndex:indexPath.row];
    [_image_preview setImage:[UIImage imageWithData:video.thumnail_image] ];
    current_url=video.my_url;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         CGRect moveFrame= _showview.frame;
                         moveFrame.origin.y = 50;
                         _showview.frame=moveFrame;
                         
                         
                         
                     }
                     completion:^(BOOL finished){
  
                        
                         
                     }];
    
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"동영상삭제"
                                      message:@"확인을 누르시면 서버에서 사라집니다."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"확인"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        
                                        Video *video=[_tableData objectAtIndex:indexPath.row];
                                        
                                        [_myInfo removeMy_videoObject:video];
                                        
                                        [_tableData removeObjectAtIndex:indexPath.row];
                                        
                                        NSError *error;
                                        // here's where the actual save happens, and if it doesn't we print something out to the console
                                        if (![_myInfo.managedObjectContext save:&error])
                                        {
                                            NSLog(@"Problem saving: %@", [error localizedDescription]);
                                        }
                                        
                                        NSLog(@"카드삭제");
                                        
                                        
                                        [_tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                        
                                    }];
        
        [alert addAction:yesButton];
        
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"취소"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       
                                       
                                       
                                   }];
        
        
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    } else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
    
}



- (IBAction)video_add_click:(id)sender {
    
    _video = (Video *)[NSEntityDescription insertNewObjectForEntityForName:@"VIdeo" inManagedObjectContext:_managedObjectContext];
    
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
    
        NSLog(@"비디오");
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        NSString *now_date= [dateFormatter stringFromDate:[NSDate date]];
    
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* tmp_name=[NSString stringWithFormat:@"/%@.mp4",now_date];
        NSString *tempPath =[documentsDirectory stringByAppendingString:tmp_name];
        BOOL success = [videoData writeToFile:tempPath atomically:NO];
    
         NSLog(@"success? %d VideoURL = %@", success,tempPath);
    
        if(success)
        {
            _video.my_url= tmp_name;
            _video.server_url=[NSString stringWithFormat:@"%@",videoURL];
        }
            
         AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
         AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
         NSError *error = NULL;
         CMTime time = CMTimeMake(1, 65);
         CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
         NSLog(@"error==%@, Refimage==%@", error, refImg);
         
         UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
         
        NSData *imageData    = UIImagePNGRepresentation(FrameImage);
        _video.thumnail_image=imageData;

   
    

    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
    NSLog(@"나와라");
    [self show_datepicker];
    
  
    
}

- (void) show_datepicker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect moveFrame= _date_picker_view.frame;
        moveFrame.origin.y = self.view.frame.size.height-_date_picker_view.frame.size.height-40;
        _date_picker_view.frame=moveFrame;
        [_delete_label setHidden:NO];
        [_progress_view setHidden:YES];
        
        
    });
    
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void) uploadVideo:(NSURL *)video_url para:(NSDictionary *)para
{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:para, @"keyName", nil];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://52.78.1.207:3000/upload/aa" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:video_url name:@"uploadFile" fileName:@"filename.mov" mimeType:@"video/quicktime" error:nil];
        
        
    } error:nil];
    
    NSLog(@"비디오전송 시도!");
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          
                           [self.progress_view setProgress:uploadProgress.fractionCompleted];
                         

                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ 구분한다 %@", response, responseObject);
                         
                          NSDictionary *diction = (NSDictionary *)responseObject;
                          NSLog(@"서버 url만 뽑는다 %@",[diction objectForKey:@"server_url"]);
                          
                          _video.server_url=[diction objectForKey:@"server_url"];
                          [_myInfo addMy_videoObject:_video];
                          
                          
                          NSError *error;
                          // here's where the actual save happens, and if it doesn't we print something out to the console
                          if (![_myInfo.managedObjectContext save:&error])
                          {
                              NSLog(@"Problem saving: %@", [error localizedDescription]);
                          }
                          

                          
                          
                          [UIView animateWithDuration:0.2
                                           animations:^{
                                               
                                               CGRect moveFrame= _date_picker_view.frame;
                                               moveFrame.origin.y = self.view.frame.size.height;
                                               _date_picker_view.frame=moveFrame;
                                           }
                                           completion:^(BOOL finished){
                                               [self.tabBarController.tabBar setHidden:NO];
                                               [_tableData addObject:_video];
                                               [_tableview reloadData];
                                           }];
                          
                      }
                  }];
    
    [uploadTask resume];
    
}



- (IBAction)date_picker_done:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HH"];
    NSInteger hours=[[dateFormatter stringFromDate:_date_picker.date] integerValue];
    [dateFormatter setDateFormat:@"mm"];
    NSInteger minutes=[[dateFormatter stringFromDate:_date_picker.date] integerValue];
    
    NSString *due_date=[self calculate_due_date:hours minutes:minutes];
    NSLog(@"만료시간 %@",due_date);
    
    NSArray *dictionKeys = @[@"id", @"date", @"image_name"];
    NSArray *dictionVals = @[@"KMK", due_date,_video.my_url];
    NSDictionary *client_data = [NSDictionary dictionaryWithObjects:dictionVals forKeys:dictionKeys];
    
    [_delete_label setHidden:YES];
    [_progress_view setHidden:NO];
    
    [self uploadVideo:[NSURL URLWithString:_video.server_url] para:client_data];
    
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
    
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    NSDate *date = [df dateFromString:d_date];
    NSLog(@"여기서 체크1 %@",date);
    _video.due_date=date;
    NSLog(@"여기서 체크2 %@",_video.due_date);
    
    
    return d_date;
}
- (IBAction)cancel:(id)sender {
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         CGRect moveFrame= _showview.frame;
                         moveFrame.origin.y = 600;
                         _showview.frame=moveFrame;
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
- (IBAction)send_kakao:(id)sender {
    
    KakaoTalkLinkObject *label= [KakaoTalkLinkObject createLabel:_video.server_url];
    [KOAppCall openKakaoTalkAppLink:@[label]];
}
- (IBAction)video_play:(id)sender {
    
    NSLog(@"동영상 재생!");
 
    NSLog(@"경로확인 %@",current_url);
  
  
    NSString *outputDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *tempPath = [outputDirectory stringByAppendingPathComponent:current_url];
     NSLog(@"경로확인2 %@",tempPath);
    NSURL *videoURL = [NSURL fileURLWithPath:tempPath];
    
    //Video
    
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
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
