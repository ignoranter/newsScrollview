//
//  ControllerScrollView.m
//  NewsChannelTop
//
//  Created by XominLee on 2016/12/5.
//  Copyright © 2017年 XominLee. All rights reserved.
//

#import "ControllerScrollView.h"

@interface ControllerScrollView () <UIScrollViewDelegate> {
    CGFloat* _offsetXs;
    NSMutableDictionary* _cachedViewControllers;
    NSMutableDictionary* _subControllers;
}
@end

@implementation ControllerScrollView


/**there may be some viewcontroller has different width,so can deal with model and return diffenent width
 */
UIKIT_STATIC_INLINE CGFloat widthForChannel(NSDictionary* channel) {
    //if (){ return ; }
    return [UIScreen mainScreen].bounds.size.width;
}

UIKIT_STATIC_INLINE Class classForChannel(NSDictionary* model) {
    if ([[model objectForKey:@"type"] isEqualToString:@"web"]) {
        return NSClassFromString(@"WebViewController");
    }
    return NSClassFromString(@"SecondViewController");
}

UIKIT_STATIC_INLINE id modelIdentifierForChannel(NSDictionary* model) {
    if (model) {
        return [model[channelIdentifer] stringByAppendingString:model[channelNameIdentifer]];
    }
    return nil;
}

- (void)dealloc {
    self.model = nil;
    if (_offsetXs) {free(_offsetXs);}

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"contentOffset" context:@selector(contentOffset)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cachedViewControllers = [NSMutableDictionary new];
        _subControllers = [NSMutableDictionary new];

        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.bounces = YES;

        [self addObserver:self forKeyPath:@"contentOffset" options:0 context:@selector(contentOffset)];
    }
    return self;
}

- (NSArray *)child {
    return [_subControllers allValues];
}

- (void)setModel:(ScrollviewModel *)model {
    if (_model != model) {
        if (_model) {
            [_model removeObserver:self forKeyPath:@"selectedIndex" context:@selector(selectedIndex)];
            [_model removeObserver:self forKeyPath:@"channels" context:@selector(channels)];
        }
        _model = model;
        if (_model) {
            [_model addObserver:self forKeyPath:@"channels" options:0 context:@selector(channels)];
            [_model addObserver:self forKeyPath:@"selectedIndex"
                        options:NSKeyValueObservingOptionOld context:@selector(selectedIndex)];
        }
        [self reloadData];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == @selector(contentOffset)) {
        if (self.dragging || self.decelerating) {
            [self updateProgress];
        }
    } else if (context == @selector(selectedIndex)) {
        NSUInteger oldIndex = [change[NSKeyValueChangeOldKey] unsignedIntegerValue];
        if (oldIndex != _model.selectedIndex) {
            [self _reposViews];
            bool moveSoFar = _model.selectedIndex > oldIndex + 1 || oldIndex > _model.selectedIndex + 1;
            if (moveSoFar) {
                [self.layer removeAnimationForKey:@"bounds.origin"];
            }
        }
    } else if (context == @selector(channels)) {
        [self reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)reloadData {
    NSParameterAssert( [NSThread isMainThread] );

    if (_model.channels.count > 0) {

        // build offset and set contentSize
        [self allocForOffsetXs:_model.channels.count + 1];

        CGFloat* offsetXs = _offsetXs;
        CGFloat offsetX = 0;
        for (id element in _model.channels){
            *offsetXs = offsetX;
            ++offsetXs;
            offsetX += widthForChannel(element);
        }
        *offsetXs = offsetX;
        self.contentSize = CGSizeMake(offsetX, self.bounds.size.height);
        [self _reposViews];
    }
    else{
        for (id element in _subControllers.objectEnumerator){
            [self recycleController:element];
        }
        [_subControllers removeAllObjects];
    }
}

- (UIViewController *)currentController {
    id identifer = [self modelIdentifierForIndex:_model.selectedIndex];
    if (identifer) {
        return _subControllers[identifer];
    }
    return nil;
}

- (void)_reposViews {
    [self layoutControllers];
    [self scrollToIndex:_model.selectedIndex];
    [self updateCurrentForLoadedController];
}

- (void)layoutControllers {
    if (_model.channels.count == 0) { return; }

    NSParameterAssert( [NSThread isMainThread] );

    NSMutableDictionary* newSubDictionary = [NSMutableDictionary new];
    NSMutableArray* delayBlocks = [NSMutableArray new];
    NSUInteger currentIndex = _model.selectedIndex;

    for (int i = -1; i < 2; ++i) {
        NSUInteger index = currentIndex + i;
        if (index < _model.channels.count) {
            id model = _model.channels[index];
            id modelIdentifier = modelIdentifierForChannel(model);
            UIViewController<ControllerScrollViewDelegate>* ctrl = _subControllers[modelIdentifier];
            if (ctrl) { //the ctrl is already loaded
                [_subControllers removeObjectForKey:modelIdentifier];
                newSubDictionary[modelIdentifier] = ctrl;

                [UIView setAnimationsEnabled:NO]; // don't animated controller frame change
                ctrl.view.frame = [self frameAtIndex:index];
                [UIView setAnimationsEnabled:YES];
            } else {
                dispatch_block_t block = ^{
                    typeof(ctrl) ctrl = [self dequeueReusableController:classForChannel(model)];
                    newSubDictionary[modelIdentifier] = ctrl;


                    [UIView setAnimationsEnabled:NO]; // don't animated show controller
                    ctrl.view.frame = [self frameAtIndex:index];
                    [self addSubview:ctrl.view];
                    if ([ctrl respondsToSelector:@selector(updateControllerWithDataSource:)]){
                        [ctrl updateControllerWithDataSource:model];
                        [UIView setAnimationsEnabled:YES];
                    }
                };
                [delayBlocks addObject:block];
            }
        }
    }

    for (id element in _subControllers.objectEnumerator){
        [self recycleController:element]; // recycle unuse controller
    }

    for (dispatch_block_t block in delayBlocks){
        block();
    }

    _subControllers = newSubDictionary;
}

- (void)scrollToIndex:(NSUInteger)index {
    NSParameterAssert( index < _model.channels.count );
    self.contentOffset = CGPointMake(_offsetXs[index], 0);
}

- (void)updateCurrentForLoadedController {
    id current = [self currentController];
    for (UIViewController<ControllerScrollViewDelegate>* element in _subControllers.objectEnumerator){
        if ([element respondsToSelector:@selector(updateControllerWithIsCurrent:)]) {
            [element updateControllerWithIsCurrent:current == element];
        }
    }
}

- (void)updateProgress {
    if (_model.channels.count == 0) {
        _model.progress = _model.selectedIndex;
        return;
    }

    CGPoint offset = self.contentOffset;
    NSUInteger index = [self indexForOffsetX:offset.x];
    CGFloat width = _offsetXs[index+1] - _offsetXs[index];
    if (width < 10) {
        width = 10;
    }
    CGFloat extend = offset.x - _offsetXs[index];
    CGFloat progress = index + extend / width;

    _model.progress = progress;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_model.channels.count == 0) { return; }

    // paging according to index;
    CGPoint offset = scrollView.contentOffset;
    NSUInteger index = [self indexForOffsetX:offset.x];

#define StayAndNearToRight (fabs(velocity.x) < 0.1 && offset.x > (_offsetXs[index + 1] + _offsetXs[index])/2)
#define CanMoveToRight (index + 1 < _model.channels.count)

    if ((velocity.x > 0 || StayAndNearToRight) && CanMoveToRight) {
        index = index + 1;
    }
    targetContentOffset->x = _offsetXs[index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_model.channels.count == 0) { return; }
    NSUInteger index = [self indexForOffsetX:scrollView.contentOffset.x];
    _model.selectedIndex = index;
}

- (NSUInteger)indexForOffsetX:(CGFloat)offsetX {
    NSUInteger count = _model.channels.count;
    NSUInteger i = 1;
    while (i < count) {
        if (_offsetXs[i] > offsetX) { return i - 1; }
        ++i;
    }
    return i - 1;
}

- (CGRect)frameAtIndex:(NSUInteger)index {
    NSParameterAssert( index < _model.channels.count );
    return (CGRect){{_offsetXs[index], 0},{_offsetXs[index+1]-_offsetXs[index], self.bounds.size.height}};
}

- (id)modelIdentifierForIndex:(NSUInteger)index {
    if (index < _model.channels.count) {
        id model = _model.channels[index];
        return modelIdentifierForChannel(model);
    }
    return nil;
}

- (UIViewController<ControllerScrollViewDelegate>*)dequeueReusableController:(Class)clazz {
    NSString* identifer = NSStringFromClass(clazz);
    NSMutableArray* bucket = _cachedViewControllers[identifer];
    UIViewController<ControllerScrollViewDelegate>* ctrl;
    if (bucket.count > 0) {
        ctrl = bucket[0];
        [bucket removeObjectAtIndex:0];
    } else {
        ctrl = [clazz new];
    }
    return ctrl;
}

- (void)recycleController:(UIViewController*)obj {
    if ( !obj ) { return; }

    NSString* identifier = NSStringFromClass(obj.class);

    NSMutableArray* bucket = _cachedViewControllers[identifier];
    if (!bucket) {
        bucket = [NSMutableArray new];
        _cachedViewControllers[identifier] = bucket;
    }

    [bucket addObject:obj];
    [obj.view removeFromSuperview];
}

- (void)allocForOffsetXs:(NSUInteger)capacity {
    if (capacity > 0) {
        size_t size = capacity * sizeof(CGFloat);
        _offsetXs = (CGFloat*)reallocf(_offsetXs, size);
    }
}

@end
