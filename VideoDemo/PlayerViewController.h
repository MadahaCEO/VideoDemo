//
//  PlayerViewController.h
//  VideoDemo
//
//  Created by Apple on 2018/9/11.
//  Copyright © 2018年 马大哈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController

@property (nonatomic) NSTimeInterval seekTime; /* 记录上一次的播放时间，再次进入直接跳到上次时间。 */

@end
