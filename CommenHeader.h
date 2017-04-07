//
//  CommenHeader.h
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/4.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#ifndef CommenHeader_h
#define CommenHeader_h

/** the channel is a dictionary like {@"channelID"  : @"id_channel_military",
 @"channelName : @"军事"}
 */
static const NSString* channelIdentifer     = @"channelID";
static const NSString* channelNameIdentifer = @"channelName";


UIKIT_STATIC_INLINE NSString* SAFE_STRING(id str) {
    return [str isKindOfClass:[NSString class]]?str:@"";
}

UIKIT_STATIC_INLINE bool IS_NONNULL_STRING(id str) {
    return [str isKindOfClass:[NSString class]] && [str length] > 0;
}

#define IS_NULL_STRING(str) (!IS_NONNULL_STRING(str))


UIKIT_STATIC_INLINE CGFloat IFScreenFit(CGFloat ip5s,CGFloat ip6,CGFloat ip6p) {
    static dispatch_once_t onceToken;
    static CGSize screenSize = CGSizeZero;
    dispatch_once(&onceToken, ^{
        screenSize = [UIScreen mainScreen].bounds.size;;
    });
    return screenSize.width==375 ? ip6 : (screenSize.width==414) ? ip6p :ip5s;
}

UIKIT_STATIC_INLINE CGFloat IFScreenFit2(CGFloat ip5s, CGFloat ip6) {
    return IFScreenFit(ip5s, ip6, ip6 * 1.104);
}

UIKIT_STATIC_INLINE CGFloat IFScreenFit2s(CGFloat ip5s) {
    return IFScreenFit(ip5s, ip5s, ip5s * 1.104);
}

UIKIT_STATIC_INLINE UIColor* RGB(uint8_t r, uint8_t g, uint8_t b){
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.f];
}

#endif /* CommenHeader_h */
