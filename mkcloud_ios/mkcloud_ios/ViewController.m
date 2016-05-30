//
//  ViewController.m
//  mkcloud_ios
//
//  Created by KMK on 2016. 5. 9..
//  Copyright © 2016년 KMK. All rights reserved.
//

#import "ViewController.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "MainViewController.h"

@interface ViewController ()

@property(strong,nonatomic) UIWindow * window;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _managedObjectContext = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    _window=[[[UIApplication sharedApplication] delegate]window];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)kakao_login:(id)sender {
    
    
   // KOSession *session = [KOSession sharedSession];
    
    [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
        
        if ([[KOSession sharedSession] isOpen]) {
            // login success.
            NSLog(@"login success.");
            
            [KOSessionTask meTaskWithCompletionHandler:^(KOUser* result, NSError* error){
                
                if (result) {
                    NSLog(@"카카오톡 프로필 가져오기 성공 %@",result);
                    
                   // NSArray *dictionKeys = @[@"type", @"id",@"nickname"];
                   // NSArray *dictionVals = @[@"login",result.ID.stringValue, [result propertyForKey:@"nickname"]];
                    
                 //   NSDictionary *kakaoData = [NSDictionary dictionaryWithObjects:dictionVals forKeys:dictionKeys];
                    
                 //   NSString *userJsonData = [Common_modules transToJson:kakaoData];
                    
                 //   [[[UIApplication sharedApplication] delegate] performSelector:@selector(connectToServer:url:) withObject:userJsonData withObject:sign_up];
                    
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    MainViewController* vc = [sb instantiateViewControllerWithIdentifier:@"MainViewController"];
                    [_window setRootViewController:vc];
                    
                    
                }
                else
                    NSLog(@"카카오톡 프로필 가져오기 실패 %@", error);
                
            }];
        }}];
    

}

@end
