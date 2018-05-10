//
//  SDMediaControl.h
//  SDIJKPlayerSSL_Example
//
//  Created by shendong on 2018/5/10.
//  Copyright © 2018年 momo13014. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IJKMediaPlayback;

UIKIT_EXTERN NSString *const KDXFullScreenStateChangedNotificaiton;

@interface SDMediaControl : UIView
- (void)showAndNoFade;
- (void)showAndFade;
- (void)hide;

- (void)refreshMediaControl;
- (void)beginDragMediaSlider;
- (void)endDragMediaSlider;
- (void)continueDragMediaSlider;
- (void)readyToDealloc;
- (void)reset;
@property (nonatomic, weak) id<IJKMediaPlayback> delegatePlayer;

@property (nonatomic, assign) BOOL playState;
@property (nonatomic, weak, readonly) UIView *overlayPanel;
@property (nonatomic, weak) UIView *maskedView;
@property (nonatomic, weak) UIView *bottomPanel;
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) UILabel *currentTimeLabel;
@property (nonatomic, weak) UILabel *totalDurationLabel;
@property (nonatomic, weak) UISlider *mediaProgressSlider;
@property (nonatomic, copy) dispatch_block_t prepareToPlayBlock;
@property (nonatomic, weak) UIButton *fullscreenButton;
@property (nonatomic, assign, readonly, getter=isFullScreenState) BOOL fullScreenState;

//! 手动触发全屏点击
- (void)manullyTapFullScreen;

- (void)autoPlay;
@end
