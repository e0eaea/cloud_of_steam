//
//  PhotoViewController.m
//  mkcloud_ios
//
//  Created by KMK on 2016. 6. 11..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import "PhotoViewController.h"
#import "CardTableViewCell.h"
#import <Photos/Photos.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "My_Info.h"
#import "Photo.h"
#import "AppDelegate.h"


@interface PhotoViewController ()<UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic) IBOutlet UITableView * tableview;
@property (nonatomic) IBOutlet UIView * showview;

@property (nonatomic)  NSMutableArray * tableData;
@property (strong, nonatomic) IBOutlet UIDatePicker *date_picker;
@property (strong, nonatomic) IBOutlet UIView *date_picker_view;
@property (strong, nonatomic) IBOutlet UIImageView *image_preview;

@property (strong, nonatomic) My_Info* myInfo;
@property (strong, nonatomic) Photo* photo;



@end

@implementation PhotoViewController

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
    NSArray *sorted_arr = [_myInfo.my_photo sortedArrayUsingDescriptors:@[due]];
    
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
    Photo *photo=[_tableData objectAtIndex:indexPath.row];
    cell.is_photo=YES;
    cell.photo=photo;
    
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
    
    Photo *photo=[_tableData objectAtIndex:indexPath.row];
 
    [_image_preview setImage:[UIImage imageWithData:photo.thumnail_image]];

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
                                      alertControllerWithTitle:@"사진삭제"
                                      message:@"확인을 누르시면 서버에서 사라집니다."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"확인"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        
                                        Photo *photo=[_tableData objectAtIndex:indexPath.row];
                                        
                                        [_myInfo removeMy_photoObject:photo];
                                        
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



- (IBAction)photo_add_click:(id)sender {
  
    _photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_managedObjectContext];
    
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    
    imagePicker.delegate = (id)self;
    
    imagePicker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    imagePicker.allowsEditing =YES;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
    

}

-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    // Code here to work with media
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    NSURL *imageFileURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    _photo.my_url=[NSString stringWithFormat:@"%@", imageFileURL];
    NSLog(@"경로는 %@",imageFileURL);
    
    NSData *imageData    = UIImagePNGRepresentation(image);
    _photo.thumnail_image=imageData;
    
    NSLog(@"나와라");
    [self show_datepicker];

}

- (void) show_datepicker
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
                         CGRect moveFrame= _date_picker_view.frame;
                         moveFrame.origin.y = self.view.frame.size.height-_date_picker_view.frame.size.height-40;
                         _date_picker_view.frame=moveFrame;
        
        
    });
    
}


-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)date_picker_done:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HH"];
    NSInteger hours=[[dateFormatter stringFromDate:_date_picker.date] integerValue];
    [dateFormatter setDateFormat:@"mm"];
    NSInteger minutes=[[dateFormatter stringFromDate:_date_picker.date] integerValue];
    
    NSString *due_date=[self calculate_due_date:hours minutes:minutes];
    NSLog(@"만료시간 %@",due_date);
    
    [_myInfo addMy_photoObject:_photo];
    
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
                         [_tableData addObject:_photo];
                         [_tableview reloadData];
                     }];
    
    
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
    _photo.due_date=date;
    NSLog(@"여기서 체크2 %@",_photo.due_date);

    
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
    
    KakaoTalkLinkObject *label= [KakaoTalkLinkObject createLabel:@"http://www.naver.com"];
     [KOAppCall openKakaoTalkAppLink:@[label]];
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
