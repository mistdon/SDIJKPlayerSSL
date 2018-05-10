//
//  SDViewController.m
//  SDIJKPlayerSSL
//
//  Created by momo13014 on 11/21/2017.
//  Copyright (c) 2017 momo13014. All rights reserved.
//

#import "SDViewController.h"
#import "SDVideoPlayerView.h"
@interface SDViewController ()

@end

@implementation SDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    static NSString *playbackUrl = @"https://media.w3.org/2010/05/sintel/trailer.mp4";
    static NSString *liveUrl     = @"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8";
    
    
    SDVideoPlayerView *playerView = [[SDVideoPlayerView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 200)];
    [self.view addSubview:playerView];
    
    [playerView setPlayingUrl:playbackUrl];
    [playerView setPlaceHolder:@"https://img1.doubanio.com/view/group_topic/large/public/p116964028.jpg"];
}
@end
