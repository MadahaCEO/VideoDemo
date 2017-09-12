//
//  MDHVideoFastForwardBackView.h
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

/******************************* 参考效果图 *********************************/

/*————————————————————————
 |                        |
 |         \              |
 |           \            |
 |             \          | ------>>>>>>  快进、快退的提示图片
 |             /          |
 |           /            |
 |         /              |
 |————————————————————————|
 |        00:32           | ------>>>>>>  时间提示
 |————————————————————————|
 |                        |
 |________________________| ------>>>>>>  进度条
 |                        |
 ————————————————————————*/



#import <UIKit/UIKit.h>

@interface MDHVideoFastForwardBackView : UIView


@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel        *alertLabel;
@property (nonatomic, strong) UIImageView    *alertImageView;


/**
 *  快进、快退提示View
 *
 *  @param progress          进度条value
 *  @param alertTime         播放时间
 *
 */
- (void)currentProgress:(CGFloat)progress alertTime:(NSString *)alertTime;

@end
