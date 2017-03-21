//
//  MyLayer.m
//  CAAnimation
//
//  Created by 董招兵 on 2017/3/2.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

#import "MyLayer.h"

@implementation MyLayer

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key {
    
    NSLog(@"\nadding animation: %@\n", [anim debugDescription]);

    [super addAnimation:anim forKey:key];
    
}


@end
