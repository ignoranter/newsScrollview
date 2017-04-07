//
//  ControllerScrollView.h
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/5.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollviewModel.h"


@protocol ControllerScrollViewDelegate <NSObject>

- (void)updateControllerWithDataSource:(NSDictionary *)channel;
- (void)updateControllerWithIsCurrent:(BOOL)isCurrent;
- (void)tabbarSelectedWithIsCurrent:(BOOL)isCurrent;

@end


@interface ControllerScrollView : UIScrollView

@property (nonatomic, strong) ScrollviewModel* model;
@property (nonatomic, copy, readonly) NSArray* child;

- (void)reloadData;
- (UIViewController*)currentController;

@end
