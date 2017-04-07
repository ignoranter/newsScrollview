//
//  ScrollviewModel.h
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/4.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScrollviewModel : NSObject

@property (nonatomic, copy) NSArray* channels;
@property (nonatomic, readonly ,copy) NSDictionary* selectedChannel;
@property (nonatomic) CGFloat progress;   ///< like selectedIndex, use decimal to represent the middle status
@property (nonatomic, readwrite,assign) NSUInteger selectedIndex; ///< selected channel Index


+ (instancetype)sharedInstance;
- (instancetype)initWithChannels:(NSArray*)channels;
- (NSDictionary*)channelAtIndex:(NSUInteger)index;
- (NSUInteger)indexForChannel:(NSDictionary*)channel;
- (NSUInteger)indexForChannelID:(NSString*)cid;
@end
