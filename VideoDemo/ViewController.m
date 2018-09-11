//
//  ViewController.m
//  VideoDemo
//
//  Created by Apple on 2017/9/7.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel   *currentTimeLabel;     // 当前播放时间

@end



@implementation ViewController



- (UILabel *)currentTimeLabel {
    
    if (!_currentTimeLabel) {
        
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height)];
        _currentTimeLabel.backgroundColor = [UIColor whiteColor];
        _currentTimeLabel.textColor = [UIColor blackColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.text = @"点一下，看视频。";
        _currentTimeLabel.font = [UIFont systemFontOfSize:30.0];
    }
    
    return _currentTimeLabel;
}




- (void)dealloc {
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.currentTimeLabel];
    
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
        
    
    
    PlayerViewController *playerVC = [[PlayerViewController alloc] init];
//    [self presentViewController:playerVC animated:YES completion:nil];
    [self.navigationController pushViewController:playerVC animated:YES];

}





#pragma mark - Notification



#pragma mark - AVAssetResourceLoaderDelegate

#pragma mark - VideoToolBarDelegate


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
