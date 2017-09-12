//
//  MDHVideoDataModel.m
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "MDHVideoDataModel.h"

@implementation MDHVideoDataModel



+ (instancetype)sharedInstance {
    
    static MDHVideoDataModel *dataModel = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dataModel = [[self alloc] init];
    });
    
    return dataModel;
}


- (instancetype)init {
    
    self = [super init];
    if (self) {
    
    }
    
    return  self;
}




- (NSString *)currentTimeString {
    
    NSString *string = nil;

    // 当前时间格式 按照 总时间来判断（如果总时间超过1小时，那么当前时间要00:01:00）
    if (self.totalSecond < 3600) {
    
        NSInteger min = self.currentSecond / 60; // 分钟
        NSInteger sec = self.currentSecond % 60; // 秒
        string        = [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
        
    } else {
    
        NSInteger hou = self.currentSecond / 3600; // 小时
        NSInteger min = self.currentSecond / 60;   // 分钟
        NSInteger sec = self.currentSecond % 60;   // 秒
        string        = [NSString stringWithFormat:@"%02zd:%02zd:%02zd",hou, min, sec];
    }
    
    return string;
}

- (NSString *)totalTimeString {

    NSString *string = nil;
    
    if (self.totalSecond < 3600) {
        
        NSInteger min = self.totalSecond / 60; // 分钟
        NSInteger sec = self.totalSecond % 60; // 秒
        string        = [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
        
    } else {
        
        NSInteger hou = self.totalSecond / 3600; // 小时
        NSInteger min = self.totalSecond / 60;   // 分钟
        NSInteger sec = self.totalSecond % 60;   // 秒
        string        = [NSString stringWithFormat:@"%02zd:%02zd:%02zd",hou, min, sec];
    }
    
    return string;
}

- (NSString *)forwardBackTimeString {
    
    return [NSString stringWithFormat:@"%@ / %@", self.currentTimeString, self.totalTimeString];
}

- (CGFloat)progress {

    return self.currentSecond / self.totalSecond;
}

@end
