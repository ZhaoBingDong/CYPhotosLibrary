//
//  CYAuthorizedFailureViewController.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/6.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYAuthorizedFailureViewController.h"

@interface CYAuthorizedFailureViewController ()

@end

@implementation CYAuthorizedFailureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(back)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];

    self.title                             = @"照片";
    
    
}

- (void)back {
    
}

- (void)dismiss {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosViewControllDismiss" object:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (IBAction)settingButtonClick:(id)sender {
    
    NSURL *url               = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
  
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];


}
@end
