//
//  ViewController.m
//  VideoDemo
//
//  Created by Apple on 2017/9/7.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "ViewController.h"

#import "MDHVideoPlayerView.h"



@interface ViewController ()


@end

@implementation ViewController


- (void)dealloc {
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"test_Video_0" ofType:@"mp4"];

    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 400);
    MDHVideoPlayerView *playerView = [[MDHVideoPlayerView alloc] initWithFrame: rect
                                                                  videoAddress: path];
    
    [self.view addSubview:playerView];

   
}





#pragma mark - Layz load




#pragma mark - Notification



#pragma mark - AVAssetResourceLoaderDelegate

#pragma mark - VideoToolBarDelegate


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
