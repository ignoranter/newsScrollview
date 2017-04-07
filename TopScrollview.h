//
//  TopScrollview.h
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/4.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopScrollviewDelegate <NSObject>

@optional
- (void)channelScrollviewDidReload;

@end

NS_ASSUME_NONNULL_BEGIN

NSString* const channelItemDidSelectedNotification = @"channelItemDidSelectedNotification";
NSString* const channelItemDidReclickNotification  = @"channelItemDidReclickNotification";


@class ScrollviewModel;
@interface TopScrollview : UIScrollView

@property (nonatomic, weak)  id<TopScrollviewDelegate> scrollDelegate;

/**@b store channel buttons,the count will be more than 1,and always change*/
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) ScrollviewModel* model;

@property (nonatomic, strong) NSMutableArray *items; ///< all buttons for channel items

@property (nonatomic, strong) UIView *selectedLine;  ///< a line under button,indicate which is current selected item
@property (nonatomic) BOOL isBottomLineShow;         ///< a line indicate the current selected item,default is YES
@property (nonatomic) CGFloat itemSpace;             ///< the space between each button items,@def default is 3
@end
NS_ASSUME_NONNULL_END
