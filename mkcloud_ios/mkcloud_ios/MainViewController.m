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

@interface MainViewController ()<UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageview;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    [_imageview setImage:image];
    
     [self dismissViewControllerAnimated:YES completion:nil];
  /*
        if([_this_card.card_images count]==0)
            [_card_image setBackgroundImage:image forState:UIControlStateNormal];
        
        NSData *imageData    = UIImagePNGRepresentation(image);
        Image * new_image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:_managedObjectContext];
   
   
        
        new_image.image=imageData;
        [_this_card addCard_imagesObject:new_image];
        
   
         NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
         
         [self request_image:image];
         
         NSData *data2 = [[NSData alloc] initWithBase64EncodedString:base64Encoded options:0];
         
         UIImage *image2 = [UIImage imageWithData:data2];
         */
        
}
    
    



-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)transfer_to_server:(id)sender {
    
    /*
    NSArray *dictionKeys = @[@"id"];
    NSArray *dictionVals = @[@"mk"];
    NSDictionary *client_data = [NSDictionary dictionaryWithObjects:dictionVals forKeys:dictionKeys];
    
    
    NSString *userJsonData = [Common_modules transToJson:client_data];
    */
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(uploadImageLegacy:json:) withObject:_imageview.image withObject:@"KMK"];
    
    NSLog(@"서버요청완료!!");
    
    
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
