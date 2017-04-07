//
//  ScrollviewModel.m
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/4.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import "ScrollviewModel.h"

@implementation ScrollviewModel{
    NSArray* _channels;
}

+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id __singletion;
    dispatch_once(&once,^{
        __singletion = [[self alloc] init];
    });
    return __singletion;
}

- (instancetype)initWithChannels:(NSArray *)channels{
    if (self = [super init]){
        _channels = channels;
    }
    return self;
}

- (NSDictionary *)channelAtIndex:(NSUInteger)index {
    if (index < _channels.count) {
        return _channels[index];
    }
    return nil;
}

- (NSUInteger)indexForChannel:(NSDictionary*)channel {
    NSString* channelID = channel[channelIdentifer];
    return [self indexForChannelID:channelID];
}

- (void)setChannels:(NSArray *)channels{
    id oldChannel = [self channelAtIndex:_selectedIndex];
    _channels = channels.copy;
    if (oldChannel) {
        NSUInteger newIndex = [self indexForChannel:oldChannel];
        if (newIndex != NSNotFound) {
            _selectedIndex = newIndex;
        }
    }
    if (_selectedIndex >= _channels.count) {
        _selectedIndex = 0;
    }
}

- (NSDictionary *)selectedChannel {
    if (_selectedIndex < _channels.count) {
        return _channels[_selectedIndex];
    }
    return nil;
}

- (NSUInteger)indexForChannelID:(NSString *)cid {
    if (IS_NULL_STRING(cid)) { return NSNotFound; }

    for (NSUInteger i = 0; i < _channels.count; i++) {
        NSDictionary* element = _channels[i];
        if ([element[channelIdentifer] isEqualToString:cid]) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSUInteger)indexForChannelName:(NSString*)name {
    return [_channels indexOfObjectPassingTest:^BOOL(NSDictionary* channel, NSUInteger idx, BOOL * _Nonnull stop){return [channel[channelNameIdentifer] isEqualToString:name];}];
}
@end
