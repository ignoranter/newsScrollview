//
//  TopScrollview.m
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/4.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import "TopScrollview.h"
#import "ScrollviewModel.h"

@implementation TopScrollview

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator   = NO;
        
        _items = [NSMutableArray.alloc init];
    }
    return self;
}

- (void)setModel:(ScrollviewModel *)model {
    if (_model != model) {
        if (_model) {
            [_model removeObserver:self forKeyPath:@"channels" context:@selector(channels)];
            [_model removeObserver:self forKeyPath:@"selectedIndex" context:@selector(selectedIndex)];
            [_model removeObserver:self forKeyPath:@"progress" context:@selector(progress)];
        }
        _model = model;
        if (_model) {
            [_model addObserver:self forKeyPath:@"channels" options:0 context:@selector(channels)];
            [_model addObserver:self forKeyPath:@"selectedIndex" options:0 context:@selector(selectedIndex)];
            [_model addObserver:self forKeyPath:@"progress" options:0 context:@selector(progress)];
        }
        [self reload];
    }
}


- (void)reload {
    for (UIButton* element in self.subviews){
        // remove buttons and decorate views
        [element removeFromSuperview];
    }
    [_items removeAllObjects];
    [self createItemsWithdefaultChannel];

    // do something business after scrollview items reloaded
    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(channelScrollviewDidReload)]) {
        [self.scrollDelegate channelScrollviewDidReload];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == @selector(progress)) {
        self.progress = _model.progress;
    } else if (context == @selector(selectedIndex)) {
        [self selectAtIndex:_model.selectedIndex];
    } else if (context == @selector(channels)) {
        [self reload];
    }
}

UIKIT_STATIC_INLINE CGFloat interpolate(CGFloat begin, CGFloat end, CGFloat fragment) {
    return begin + (end - begin) * fragment;
}

#define SetBtnColor(index, interpolateValue)                                  \
      if (index < _items.count) {                                             \
          btn = _items[index];                                                \
        color = [UIColor colorWithRed:interpolate(r1, r2, interpolateValue)   \
                                green:interpolate(g1, g2, interpolateValue)   \
                                 blue:interpolate(b1, b2, interpolateValue)   \
                                alpha:interpolate(a1, a2, interpolateValue)]; \
        [btn setTitleColor:color forState:UIControlStateNormal];              \
        btn.transform = CGAffineTransformMakeScale(1-0.11*interpolateValue, 1-0.11*interpolateValue);}


- (void)setProgress:(CGFloat)progress{
    // ensure safety
    if (_items.count == 0) { return; }
    if (progress < 0) { progress = 0;}
    else if (progress + 1 > _items.count) {
        progress = _items.count - 1;
    }

    if (_progress != progress) {
        // interpolate title Colors between titleColor and selectedTitleColor
        NSUInteger floorIndex,ceilIndex;
        CGFloat    fragment;

        UIButton* btn;
        UIColor* selectedColor = RGB(0xf5, 0x48, 0x43);
        UIColor* normalColor   = RGB(0x5c, 0x5f, 0x5c);

        // clear old interpolate state
        floorIndex = floor(_progress);
        ceilIndex  = floorIndex + 1;

        if (floorIndex < _items.count) {
            btn = _items[floorIndex];
            [btn setTitleColor:normalColor forState:UIControlStateNormal];
            btn.transform = CGAffineTransformMakeScale(0.89,0.89);
        }
        if (ceilIndex < _items.count) {
            btn = _items[ceilIndex];
            [btn setTitleColor:normalColor forState:UIControlStateNormal];
            btn.transform = CGAffineTransformMakeScale(0.89,0.89);
        }

        // interpolate new Colors
        floorIndex = floor(progress);
        ceilIndex  = floorIndex + 1;
        fragment   = progress - floorIndex;

        if (fragment > 1e-3) {
            CGFloat r1,g1,b1,a1, r2,g2,b2,a2;
            UIColor* color;
            [selectedColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
            [normalColor   getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

            SetBtnColor(floorIndex, fragment);
            SetBtnColor(ceilIndex, (1-fragment));

            // interpolate selectedLine
            if (ceilIndex < _items.count) {
                btn = _items[floorIndex];
                CGFloat floorWidth = btn.frame.size.width;
                CGFloat floorCenterX = btn.center.x;
                btn = _items[ceilIndex];

                CGFloat ceilWidth = btn.frame.size.width
                ,ceilCenterX = btn.center.x
                ,centerX = interpolate(floorCenterX, ceilCenterX, fragment)
                ,lineHeight = IFScreenFit2s(2);

                if((progress-(int)progress)<0.5){
                    self.selectedLine.frame = CGRectMake(
                                                         floorCenterX-(floorWidth*0.2/2),
                                                         self.contentSize.height - lineHeight,
                                                         floorWidth*0.2+2*(centerX-floorCenterX),
                                                         lineHeight);
                }else{
                    self.selectedLine.frame = CGRectMake(ceilCenterX+(ceilWidth*0.2/2)
                                                         -(ceilWidth*0.2+(ceilCenterX-centerX)*2),
                                                         self.contentSize.height-lineHeight,
                                                         ceilWidth*0.2+(ceilCenterX-centerX)*2,
                                                         lineHeight);
                }
            }
        } else {
            UIButton* floorBtn = _items[floorIndex];
            floorBtn.transform = CGAffineTransformMakeScale(1, 1);
            [floorBtn setTitleColor:selectedColor forState:UIControlStateNormal];
            CGFloat const lineHeight = IFScreenFit2s(2.f),
            width = floorBtn.frame.size.width,
            centerX = floorBtn.center.x;
            self.selectedLine.frame = CGRectMake(centerX-width*0.2/2, self.contentSize.height - lineHeight,width*0.2, lineHeight);
        }
        _progress = progress;
    }
}

- (void)createItemsWithdefaultChannel{

    NSArray* channels = _model.channels;
    CGFloat const space = self.itemSpace ? self.itemSpace : IFScreenFit2s(3);
    CGFloat x = 0;

    for (NSUInteger i = 0; i < channels.count; i++) {
        NSDictionary* channel = channels[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:IFScreenFit2s(18)];
        [button setTitleColor:RGB(0x8f,0x8f, 0x8f) forState:UIControlStateNormal];
        [button setTitle:channel[channelNameIdentifer] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectChannelButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, IFScreenFit2s(9), 0, IFScreenFit2s(9))];
        CGSize size = [button sizeThatFits:CGSizeMake(CGFLOAT_MAX, 30)];

        [button setFrame:(CGRect){ {x, IFScreenFit2s(9)}, size}];
        x += size.width + space;
        button.transform = CGAffineTransformMakeScale(0.89, 0.89);
        [button setTag:i+100];

        [self addSubview:button];
        [_items addObject:button];
    }
    UIButton *lastButton = [_items lastObject];
    self.contentSize = CGSizeMake(lastButton.frame.origin.x + lastButton.frame.size.width, self.frame.size.height);

    [self createDecorateViews];

    NSUInteger selectedIndex = _model.selectedIndex;
    if (selectedIndex < _items.count) {
        // reset to invalid _progress
        _progress = _items.count;
        [self selectAtIndex:selectedIndex];
    }
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}

- (void)selectAtIndex:(NSUInteger)index {
    if (index >= _items.count) return;

    self.progress = index;

    CATransition* transition = [CATransition animation];
    for (UIButton* element in _items){
        [element.layer addAnimation:transition forKey:@"foregroundColor"];
    }

    UIButton* selectedButton = _items[index];
    [NSNotificationCenter.defaultCenter postNotificationName:channelItemDidSelectedNotification object:selectedButton userInfo:nil];

    // scroll to visible
    // now try make selectedButton as the center as possible, but not extend edge
    CGFloat x = selectedButton.center.x - self.frame.size.width/2;
    CGFloat const maxX = self.contentSize.width - self.frame.size.width + self.contentInset.right,
    minX = -self.contentInset.left;
    if (x > maxX) { x = maxX; }
    if (x < minX) { x = minX; }
    [self setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)selectChannelButton:(UIButton*)sender{
    NSUInteger index = sender.tag - 100;
    if (index < _model.channels.count) {
        if (index == _model.selectedIndex) {
            // reclick the channel button
            [NSNotificationCenter.defaultCenter postNotificationName:channelItemDidReclickNotification
                                                              object:self
                                                            userInfo:@{@"index": @(index)}];
        } else {
            [UIView animateWithDuration:0.25 animations:^(void){
                _model.selectedIndex = index;
            }];
        }
    }
}

- (void)createDecorateViews{
    self.selectedLine = [UIView.alloc init];
    self.selectedLine.backgroundColor = RGB(0xf5, 0x43, 0x43);
    [self addSubview:self.selectedLine];

    self.selectedLine.layer.masksToBounds = YES;
    self.selectedLine.layer.cornerRadius = IFScreenFit2s(1.f);
}

@end
