//
//  WebViewController.m
//  NewsChannelTop
//
//  Created by LiXiangming on 2017/4/6.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:self.webview];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{

}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

}
@end
