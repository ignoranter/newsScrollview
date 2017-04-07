//
//  WebViewController.h
//  NewsChannelTop
//
//  Created by LiXiangming on 2017/4/6.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebViewController : UIViewController<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView* webview;
@end
