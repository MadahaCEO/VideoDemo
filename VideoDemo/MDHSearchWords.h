//
//  MDHSearchWords.h
//  VideoDemo
//
//  Created by Apple on 2018/9/18.
//  Copyright © 2018年 马大哈. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, SearchWordsOptions) {
  
    SearchWordsOptions_Hello = (1 << 0),
    SearchWordsOptions_Hi = (1 << 1),
    SearchWordsOptions_You = (1 << 2),
    SearchWordsOptions_Me = (1 << 3),
    SearchWordsOptions_He = (1 << 4),

};

@interface MDHSearchWords : NSObject


@property (nonatomic, assign) SearchWordsOptions options;


- (void)searchKeyWords;

@end
