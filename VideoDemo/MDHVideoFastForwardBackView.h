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


@property (nonatomic, strong) UIProgressView *progressView;    // 进度
@property (nonatomic, strong) UILabel        *alertLabel;      // 时间
@property (nonatomic, strong) UIImageView    *alertImageView;  // 提示图


/**
 *  快进、快退提示View
 *
 *  @param forward          是否快进
 *  @param progress         进度条value
 *  @param alertTime        快进或退格式字符串
 *
 */
- (void)updateImage:(BOOL)forward
           progress:(CGFloat)progress
          alertTime:(NSString *)alertTime;

@end
