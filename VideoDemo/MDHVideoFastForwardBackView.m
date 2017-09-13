//
//  MDHVideoFastForwardBackView.m
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "MDHVideoFastForwardBackView.h"
#import "Masonry.h"


@interface MDHVideoFastForwardBackView ()



@end



static const CGFloat KAlertImageHeight     = 50;
static const CGFloat KAlertLabelHeight     = 20;
static const CGFloat KControlPadding       = 10; // 间隔 10


@implementation MDHVideoFastForwardBackView

- (void)dealloc {
    
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self addSubview:self.alertImageView];
        [self addSubview:self.alertLabel];
        [self addSubview:self.progressView];
        
        [self.alertImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(@(KControlPadding/2));
            make.left.right.equalTo(@0);
            make.height.equalTo(@(KAlertImageHeight));
        }];
        
        [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(@0);
            make.top.equalTo(self.alertImageView.mas_bottom);
            make.height.equalTo(@(KAlertLabelHeight));
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(@(KControlPadding));
            make.right.equalTo(@(-KControlPadding));
            make.top.equalTo(self.alertLabel.mas_bottom).offset(KControlPadding);
        }];
    }
    
    return  self;
}



#pragma mark - For outer

- (void)updateImage:(BOOL)forward
           progress:(CGFloat)progress
          alertTime:(NSString *)alertTime {

    if (forward) {
//        NSLog(@"快进");
        self.alertImageView.image = [UIImage imageNamed:@"mdh_video_tool_forwardImage"];
    } else {
//        NSLog(@"快退");
        self.alertImageView.image = [UIImage imageNamed:@"mdh_video_tool_backImage"];
    }
    
    self.alertLabel.text       = alertTime;
    self.progressView.progress = progress;
    
}


#pragma mark - Layz load

- (UIImageView *)alertImageView {
    if (!_alertImageView) {
        _alertImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _alertImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _alertImageView;
}

- (UILabel *)alertLabel {
    if (!_alertLabel) {
        _alertLabel               = [[UILabel alloc] initWithFrame:CGRectZero];
        _alertLabel.textColor     = [UIColor whiteColor];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.font          = [UIFont systemFontOfSize:14.0];
    }
    return _alertLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.progressTintColor = [UIColor whiteColor];
        _progressView.trackTintColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    }
    return _progressView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
