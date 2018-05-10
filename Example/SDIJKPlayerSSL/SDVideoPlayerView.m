//
//  SDVideoPlayerView.m
//  SDIJKPlayerSSL_Example
//
//  Created by shendong on 2018/5/10.
//  Copyright © 2018年 momo13014. All rights reserved.
//

#import "SDVideoPlayerView.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Masonry/Masonry.h>

static NSString *const KPlayErrorMsg = @"出错了,请重试！";

@interface SDVideoPlayerView()

@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation SDVideoPlayerView
// MARK: - lazy load
- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame = self.bounds;
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}
- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}
- (SDMediaControl *)mediaControl{
    if (!_mediaControl) {
        _mediaControl = [[SDMediaControl alloc] init];
        [self addSubview:_mediaControl];
        [_mediaControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        __weak typeof(self)weakself = self;
        _mediaControl.prepareToPlayBlock = ^{
            [weakself tryToPlay];
        };
    }
    return _mediaControl;
}
// MARK: - life cycle
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
// MARK: - setter && getter
- (void)setPlayingUrl:(NSString * _Nonnull)playingUrl{
    _playingUrl  = playingUrl;
    if (_playingUrl != nil) {
        [self shutDownAndRemovePlayer];
    }
}
- (void)setPlaceHolder:(NSString *)placeholder{
    if (placeholder.length == 0) return;
    [self.coverImageView yy_setImageWithURL:[NSURL URLWithString:placeholder] placeholder:nil];
}
// MARK: - private method
- (void)setup{
    [self addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
- (void)tryToPlay{
    if(self.playingUrl.length == 0){
        [SVProgressHUD showInfoWithStatus:KPlayErrorMsg];
        [self reset];
        return;
    }

    if (!_player) {
        [self readyToPlay:self.playingUrl];;return;
    }
    if (!self.player.isPreparedToPlay) {
        [SVProgressHUD showInfoWithStatus:KPlayErrorMsg];;return;
    }
    if (![self.player isPlaying]) {
        [self.player play];
        
    }else{
        [self.player pause];
       
    }
}

- (void)readyToPlay:(NSString *)url{
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setPlayerOptionIntValue:256 forKey:@"vol"];
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url] withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.shouldAutoplay = YES;
    [self addSubview:self.player.view];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self insertSubview:self.player.view belowSubview:self.mediaControl];
    [self installMovieNotificationObservers];
    [self.indicatorView startAnimating];
    self.mediaControl.delegatePlayer = self.player;
    
    [self.mediaControl refreshMediaControl];
    [self.player prepareToPlay];
}

- (void)shutDownAndRemovePlayer{
    [self.player stop];
    [self.player shutdown];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"IJKSDLGLView")]) {
            [obj removeFromSuperview];
            *stop = YES;
        };
    }];
    _player = nil;
    self.mediaControl.delegatePlayer = nil;
}
- (void)reset{
    if (_player != nil) {
        [self shutDownAndRemovePlayer];
    }
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself showPauseStatus:YES];
    });
}
- (void)autoPlay{
    if (self.playingUrl.length == 0) return;
    [self.mediaControl autoPlay];
}
//! 显示暂停状态
- (void)showPauseStatus:(BOOL)show{
    self.mediaControl.playState = !show;
}

#pragma mark - notification
/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}
- (void)loadStateDidChange:(NSNotification*)notification{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %lu", (long)loadState);
        [self.indicatorView stopAnimating];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %lu", (long)loadState);
        [self.indicatorView startAnimating];
    } else {
        NSLog(@"loadStateDidChange: ??? : %lu", (long)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    switch (reason){
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            [SVProgressHUD showInfoWithStatus:KPlayErrorMsg];
            [self shutDownAndRemovePlayer];
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification{
    
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    switch (_player.playbackState){
        case IJKMPMoviePlaybackStateStopped: {
            [self showPauseStatus:YES];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %lu: stoped", (long)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %lu: playing", (long)_player.playbackState);
            [self showPauseStatus:NO];
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            [self showPauseStatus:YES];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %lu: paused", (long)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            [self showPauseStatus:YES];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %lu: interrupted", (long)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %lu: seeking", (long)_player.playbackState);
            
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %lu: unknown", (long)_player.playbackState);
            break;
        }
    }
}
- (void)dealloc{
    [self.player shutdown];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
