//
//  CYPhotoLibrayGroupCell.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotoLibrayGroupCell.h"

@implementation CYPhotoLibrayGroupCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.accessoryType                = UITableViewCellAccessoryDisclosureIndicator;
    self.photoImageView.contentMode   = UIViewContentModeScaleAspectFill;
    self.photoImageView.clipsToBounds = YES;
    [self.photoImageView setImage:[UIImage imageNamed:@"xiangqing_add2"]];
    
}

- (void)dealloc {
    
//    CYLog(@"--dealloc--\n");

}

@end
