//
//  CYPhoto.m
//  CYPhotoKit
//
//  Created by dongzb on 16/3/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhoto.h"
#import "CYPhotosAsset.h"

@implementation CYPhoto

- (void)setPhotosAsset:(CYPhotosAsset *)photosAsset {
    _photosAsset = photosAsset;
    self.asset   = _photosAsset.asset;
}
@end
