//
//  MDHSearchWords.m
//  VideoDemo
//
//  Created by Apple on 2018/9/18.
//  Copyright © 2018年 马大哈. All rights reserved.
//

#import "MDHSearchWords.h"

@interface MDHSearchWords ()

//@property (nonatomic, copy) NSString *testString;

@end



@implementation MDHSearchWords

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)searchKeyWords {
    
    /*
     按位与&（位运算时，相同为1，不同为0）
     按位或 |（位运算时，有1为1，全0为0）
     按位异或 ^（位运算时，相同为0，不同为1）
     按位取反~（0变1,1变0）
     
     左移《  把整数a的各二进位全部左移n位，高位丢弃，低位补0。左移n位其实就是乘以2的n次方
     右移》  把整数a的各二进位全部右移n位，保持符号位不变，符号位补齐。右移n位其实就是除以2的n次方
     */
    if (self.options & SearchWordsOptions_Hello) {
        NSLog(@"是否查询 Hello");
    }
    
    if (self.options & SearchWordsOptions_Hi) {
        NSLog(@"是否查询 Hi");
    }
    
    if (self.options & SearchWordsOptions_You) {
        NSLog(@"是否查询 You");
    }
    
    if (self.options & SearchWordsOptions_Me) {
        NSLog(@"是否查询 Me");
    }
    
    if (self.options & SearchWordsOptions_He) {
        NSLog(@"是否查询 He");
    }
    
}

@end
