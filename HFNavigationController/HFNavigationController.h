//
//  HFNavigationController.h
//  HFNavigationController
//
//  Created by xhf on 16/5/11.
//  Copyright © 2016年 xuhongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PopAnimationTypeLiner,      //线性动画，默认动画方式
    PopAnimationTypeCurtain,    //幕布式动画
    PopAnimationTypeScale,      //缩放式动画
} PopAnimationType;

@interface HFNavigationController : UINavigationController

//是否支持手势返回
@property (nonatomic, assign) BOOL canInteractive;

@property (nonatomic, assign) PopAnimationType popAnimationType;

@end
