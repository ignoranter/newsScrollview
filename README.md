# newsScrollview
code contail a topscrollview and a model , a controllerscrollview,

use it like 
    [[ScrollviewModel sharedInstance] initWithChannels:@[@{@"channelID"  : @"channelId_toutiao",
                                                           @"channelName": @"头条",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_local",
                                                           @"channelName": @"北京",
                                                           @"type"       : @"web"},
                                                         @{@"channelID"  : @"channelId_yule",
                                                           @"channelName": @"娱乐",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_junshi",
                                                           @"channelName": @"军事",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_video",
                                                           @"channelName": @"视频",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_meinv",
                                                           @"channelName": @"美女",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_duanzi",
                                                           @"channelName": @"段子",
                                                           @"type"       : @"web"},
                                                         @{@"channelID"  : @"channelId_keji",
                                                           @"channelName": @"科技",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_fang",
                                                           @"channelName": @"房产",
                                                           @"type"       : @"normal"},
                                                         @{@"channelID"  : @"channelId_zhibo",
                                                           @"channelName": @"直播",
                                                           @"type"       : @"normal"},
                                                         ]];


    
    self.topScrollview = [TopScrollview.alloc initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 41)];
    _topScrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, IFScreenFit2s(45.f));
    _topScrollview.scrollsToTop = NO;
    [self.view addSubview:_topScrollview];
    _topScrollview.model = [ScrollviewModel sharedInstance];

    self.controllerScrollview = [ControllerScrollView.alloc initWithFrame:CGRectMake(0, self.topScrollview.frame.origin.y+self.topScrollview.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_controllerScrollview];
    self.controllerScrollview.model = [ScrollviewModel sharedInstance];
