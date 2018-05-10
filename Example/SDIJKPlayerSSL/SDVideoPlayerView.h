//
//  SDVideoPlayerView.h
//  SDIJKPlayerSSL_Example
//
//  Created by shendong on 2018/5/10.
//  Copyright © 2018年 momo13014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDMediaControl.h"

@protocol IJKMediaPlayback;

@interface SDVideoPlayerView : UIView

@property (nonatomic, nullable) id<IJKMediaPlayback> player;
//! 视频播放url
@property (nonatomic, nonnull) NSString *playingUrl;
//! 封面图
@property (nonatomic, copy, nonnull) NSString *placeHolder;

@property (nonatomic) SDMediaControl *mediaControl;

@end
