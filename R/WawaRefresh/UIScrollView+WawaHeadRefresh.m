//
//  UIScrollView+WawaHeadRefresh.m
//  R
//
//  Created by macRong on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "UIScrollView+WawaHeadRefresh.h"
#import "WawaLoadingView.h"
#import <objc/runtime.h>

extern BOOL WawaPullBomb;
#pragma mark -############################# WawaHeadView #################################################

@interface WawaHeadRefreshView()
{
    CGFloat _preValue;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) WawaLoadingView *loadingView;
@property (nonatomic, copy) dispatch_block_t startRefreshActionHandler;
@property (nonatomic, assign) BOOL isObserving;

@end


#pragma mark -############################# UIScrollView (WawaHeadRefresh) #################################################

static char WawaHeadRefreshViewKey;

@implementation UIScrollView (WawaHeadRefresh)
@dynamic wawaHeadRefresh;
@dynamic isShowHeadRefresh;

- (void)wawaHeadRefresh:(dispatch_block_t)actionHandler
{
    [self wawaHeadRefreshWithpostion:WawaHeadRefreshPositionToBack actionHandler:actionHandler];
}

- (void)wawaHeadRefreshWithpostion:(WawaHeadRefreshPosition)position actionHandler:(dispatch_block_t)actionHandler
{
    if (!self.wawaHeadRefresh)
    {
        CGFloat origin_y;
        switch (position) {
            case WawaHeadRefreshPositionTop:
                origin_y = -WAWALOADINGHEIGHT;
                break;
                
            case WawaHeadRefreshPositionToBack:
                origin_y = self.contentInset.top;
                break;
            default:
                break;
        }
        
        WawaHeadRefreshView *headView = [[WawaHeadRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, WAWALOADINGHEIGHT)];
        self.wawaHeadRefresh = headView;
        headView.scrollView = self;
        headView.startRefreshActionHandler = actionHandler;
        
        self.isShowHeadRefresh = YES;
    }
}


#pragma mark -############################ Setter/Getter ###################################################

- (void)setWawaHeadRefresh:(WawaHeadRefreshView *)wawaHeadRefresh
{
    if (wawaHeadRefresh != self.wawaHeadRefresh)
    {
        [self.wawaHeadRefresh removeFromSuperview];
        [self insertSubview:wawaHeadRefresh atIndex:0];
        
        [self willChangeValueForKey:@"wawaHeadRefresh"];
        objc_setAssociatedObject(self, &WawaHeadRefreshViewKey, wawaHeadRefresh, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"wawaHeadRefresh"];
    }
}

- (WawaHeadRefreshView *)wawaHeadRefresh
{
    return objc_getAssociatedObject(self, &WawaHeadRefreshViewKey);
}

- (void)setIsShowHeadRefresh:(BOOL)isShowHeadRefresh
{
    if (!self.wawaHeadRefresh.isObserving)
    {
        [self addObserver:self.wawaHeadRefresh forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
//        [self addObserver:self.wawaHeadRefresh forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    //    [self addObserver:self.wawaHeadRefresh forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

@end


#pragma mark - ############################# WawaHeadView #################################################

@implementation WawaHeadRefreshView
{
    BOOL _isRefreshing;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _preValue = CGFLOAT_MIN;
        (void)self.loadingView;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil && self.isObserving)
    {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.isObserving = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint pin =  [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (pin.y >0)
        {
            return;
        }
        
        CGPoint p = [self.scrollView.panGestureRecognizer velocityInView:self.scrollView];
         CGFloat f =   self.scrollView.decelerationRate;
//        NSLog(@"========11111===== %@, f=%f",NSStringFromCGPoint(p),f);
//        if (self.scrollView.isDragging)
    
            // set headView postion
            [self setHeadViewPoisition:pin.y];
            
            // set loading value
            [self setLoadingPoint:pin.y];
        
        
//        NSLog(@" ==== point = %@,self.frame=%f ,l=%f",NSStringFromCGPoint(pin),self.frame.origin.y,currentHeight*12/WAWALOADINGHEIGHT-12);
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self layoutSubviews];
        
        CGFloat yOrigin = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
      
//        self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
        NSLog(@"------------contsize=%f",yOrigin);
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self layoutSubviews];
    }
}


#pragma mark -############################# Out ############################################################

- (void)beginRefreshing
{
    NSLog(@"==== beigin");
}

- (void)endRefreshing
{
    if (self.loadingView.isAnimation)
    {
        [UIView animateWithDuration:0.4f animations:^{
            self.transform =  CGAffineTransformScale(CGAffineTransformIdentity, 0.3f, 0.3f);
            UIEdgeInsets contentInset = self.scrollView.wawa_contentInset;
            contentInset.top -= WAWALOADINGHEIGHT;
            self.scrollView.contentInset = contentInset;
            [self setSelfOffSetY:self.scrollView.contentOffset.y];
            
        }completion:^(BOOL finished) {
            [self resetLoadView];
        }];
    }
}

- (void)resetLoadView
{
    if (_loadingView)
    {
        [_loadingView stopAnimation];

        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }

    _isRefreshing = NO;
    self.transform = CGAffineTransformIdentity;
}


#pragma mark -############################# Private ############################################################

- (void)setSelfOffSetY:(CGFloat)y
{
    CGRect oriRect = self.frame;
    oriRect.origin.y =  y +  self.scrollView.wawa_contentInset.top;
    self.frame = oriRect;
}

- (void)setHeadViewPoisition:(CGFloat)y
{
    /** warning */
    if (y == -WAWALOADINGHEIGHT)
    {
        if (!self.loadingView.isAnimation)
        {
            [self resetLoadView];
        }
    }
    
    if (self.loadingView.isAnimation)
    {
        CGRect oriRect = self.frame;
        oriRect.origin.y =  y +  self.scrollView.wawa_contentInset.top - WAWALOADINGHEIGHT;
        self.frame = oriRect;
         return;
    }
    
    [self setSelfOffSetY:y];
}

- (void)setLoadingPoint:(CGFloat)y
{
    if (self.loadingView.isAnimation)
    {
        return;
    }
    
    CGFloat value = fabs(y);
    if (_preValue == CGFLOAT_MIN)
    {
        _preValue = value;
    }
        
    CGFloat currentHeight = fabs(_preValue - value);
    [self.loadingView setLoaingValue:currentHeight*12.0f/WAWALOADINGHEIGHT-12.0f];
    
    __weak typeof(self)weakSelf = self;
    self.loadingView.loadingBlock = ^{
        typeof(weakSelf)SSelf = weakSelf;
        _isRefreshing = YES;
        WawaPullBomb = YES;
        SSelf.startRefreshActionHandler();
        
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets contentInset = SSelf.scrollView.contentInset;
            contentInset.top += WAWALOADINGHEIGHT;
            SSelf.scrollView.contentInset = contentInset;
        }];
    };
}

- (WawaLoadingView *)loadingView
{
    if (!_loadingView)
    {
        CGFloat loadingView_W_H = 28.0f;
        WawaLoadingView *view = [[WawaLoadingView alloc]initWithFrame:CGRectMake(self.center.x-loadingView_W_H/2,
                                                                                 (WAWALOADINGHEIGHT-loadingView_W_H)/2-loadingView_W_H/5,
                                                                                 loadingView_W_H,
                                                                                 loadingView_W_H)];
        [self addSubview:view];

        _loadingView = view;
    }
    
    return _loadingView;
}


@end
