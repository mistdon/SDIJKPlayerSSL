//
//  SDMediaControl.m
//  SDIJKPlayerSSL_Example
//
//  Created by shendong on 2018/5/10.
//  Copyright © 2018年 momo13014. All rights reserved.
//

#import "SDMediaControl.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import <Masonry/Masonry.h>

NSString *const KSDFullScreenStateChangedNotificaiton = @"KDXFullScreenStateChangedNotificaiton.com.sd";

@implementation SDMediaControl{
    BOOL _isMediaSliderBeingDragged;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return  self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (void)setup{
    UIView *overlay = [UIView new];
    [self addSubview:overlay];
    [overlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self->_overlayPanel = overlay;
    
    UIView *maskView = [UIView new];
    [self.overlayPanel addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.overlayPanel);
    }];
    
    UIView *mask = [UIView new];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.3;
    [maskView addSubview:mask];
    [mask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.overlayPanel);
    }];
    
    UIImageView *playImage = [UIImageView new];
    playImage.image = [UIImage imageNamed:@"icon_big_play"];
    playImage.contentMode = UIViewContentModeScaleAspectFit;
    [maskView addSubview:playImage];
    [playImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    self.maskedView = maskView;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAction)];
    [self addGestureRecognizer:tap];
    
    UIButton *fullscreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullscreen setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
    fullscreen.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [fullscreen addTarget:self action:@selector(fullScreenTapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayPanel addSubview:fullscreen];
    [fullscreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-5);
        make.bottom.equalTo(self).offset(-5);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    self.fullscreenButton = fullscreen;
    [self setupSubView];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self playAction];
}
- (UILabel *)sd_controlLabel{
    UILabel *label = [UILabel new];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
- (void)playAction{
    self.playState = !self.playState;
    if (self.prepareToPlayBlock) {
        self.prepareToPlayBlock();
    }
}
- (void)autoPlay{
    [self playAction];
}
// MARK: - getter && getter
- (void)setPlayState:(BOOL)playState{
    _playState = playState;
    self.maskedView.hidden = playState;
    if (_playButton) {
        _playButton.selected = playState;
    }
    
}
- (void)setupSubView{
    UIView *bottomLeftView = [UIView new];
    [self.overlayPanel addSubview:bottomLeftView];
    [bottomLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(self.overlayPanel);
        make.height.mas_equalTo(50.f);
        make.trailing.equalTo(self.fullscreenButton.mas_leading).offset(-5);
    }];
    self.bottomPanel = bottomLeftView;
    // 播放/暂停
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomPanel addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomPanel).offset(5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.equalTo(self.bottomPanel);
    }];
    self.playButton = btn;
    // 当前时长
    UILabel *currentLabel = [self sd_controlLabel];
    [self.bottomPanel addSubview:currentLabel];
    [currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(btn.mas_trailing).offset(5);
        make.centerY.equalTo(self.bottomPanel);
    }];
    self.currentTimeLabel = currentLabel;
    // 总时长
    UILabel *totalLabel = [self sd_controlLabel];
    [self.bottomPanel addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bottomPanel).offset(-5);
        make.centerY.equalTo(self.bottomPanel);
    }];
    self.totalDurationLabel = totalLabel;
    // 滚轮
    UISlider *slider = [UISlider new];
    [slider setMinimumTrackTintColor:[UIColor colorWithRed:28 green:151 blue:255 alpha:1.0]];
    [slider setMaximumTrackTintColor:[UIColor whiteColor]];
    [slider setThumbImage:[UIImage imageNamed:@"rot"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(didSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(didSliderTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [slider addTarget:self action:@selector(didSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(didSliderTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [slider addTarget:self action:@selector(didSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.bottomPanel addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(currentLabel.mas_trailing).offset(10);
        make.trailing.equalTo(totalLabel.mas_leading).offset(-10);
        make.centerY.equalTo(self.bottomPanel);
    }];
    self.mediaProgressSlider = slider;
}
// MARK: - public method
- (void)beginDragMediaSlider{
    _isMediaSliderBeingDragged = YES;
}
- (void)endDragMediaSlider{
    _isMediaSliderBeingDragged = NO;
}
- (void)continueDragMediaSlider{
    [self refreshMediaControl];
}
- (void)showAndNoFade{
    self.overlayPanel.hidden = NO;
    [self cancelDelayedHide];
    [self refreshMediaControl];
}
- (void)showAndFade{
    [self showAndNoFade];
    [self performSelector:@selector(hide) withObject:nil afterDelay:5];
}
- (void)hide{
    self.overlayPanel.hidden = YES;
    [self cancelDelayedHide];
}
- (void)reset{
    [self showAndNoFade];
    if (_bottomPanel && _bottomPanel.superview) {
        [_bottomPanel removeFromSuperview];
    }
}
- (void)cancelDelayedHide{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
}
- (void)refreshMediaControl{
    // duration
    NSTimeInterval duration = self.delegatePlayer.duration;
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        self.mediaProgressSlider.maximumValue = duration;
        self.totalDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
    } else {
        self.totalDurationLabel.text = @"--:--";
        self.mediaProgressSlider.maximumValue = 1.0f;
    }
    // position
    NSTimeInterval position;
    if (_isMediaSliderBeingDragged) {
        position = self.mediaProgressSlider.value;
    } else {
        position = self.delegatePlayer.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    if (intDuration > 0) {
        self.mediaProgressSlider.value = position;
    } else {
        self.mediaProgressSlider.value = 0.0f;
    }
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
}
- (void)didSliderTouchDown{
    [self beginDragMediaSlider];
}

- (void)didSliderTouchCancel{
    [self endDragMediaSlider];
}

- (void)didSliderTouchUpOutside{
    [self endDragMediaSlider];
}

- (void)didSliderTouchUpInside{
    [self.delegatePlayer setCurrentPlaybackTime:self.mediaProgressSlider.value];
    [self endDragMediaSlider];
}

- (void)didSliderValueChanged{
    [self continueDragMediaSlider];
}
- (void)readyToDealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
}
- (void)manullyTapFullScreen{
    [self fullScreenTapAction:nil];
}
// MARK: - Target - Action
- (void)fullScreenTapAction:(UIButton *)sender{
    self.fullscreenButton.selected = !self.fullscreenButton.selected;
    self->_fullScreenState = self.fullscreenButton.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:KSDFullScreenStateChangedNotificaiton object:@(self.fullScreenState)];
}

@end
