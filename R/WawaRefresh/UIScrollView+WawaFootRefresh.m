//
//  UIScrollView+WawaFootRefresh.m
//  R
//
//  Created by 荣守振 on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "UIScrollView+WawaFootRefresh.h"
#import <objc/runtime.h>

static char WawaFootRefreshViewKey;

#pragma mark -############################# WawaFootRefreshView ##########################################

@interface WawaFootRefreshView()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, copy) dispatch_block_t startRefreshActionHandler;

@end

#pragma mark -############################# UIScrollView+WawaFootRefresh ##################################

@implementation UIScrollView (WawaFootRefresh)
@dynamic wawaFootRefresh;
@dynamic isShowFootRefresh;

- (void)wawaFootRefresh:(dispatch_block_t)actionHandler
{
    [self wawaFootRefreshWithpostion:WawaFootRefreshPositionScrollViewBottom actionHandler:actionHandler];
}

- (void)wawaFootRefreshWithpostion:(WawaFootRefreshPosition)position actionHandler:(dispatch_block_t)actionHandler
{
    CGFloat originY = position == WawaFootRefreshPositionScrollViewBottom ? self.bounds.size.height : self.contentSize.height;
    WawaFootRefreshView *footRefreshView = [[WawaFootRefreshView alloc]initWithFrame:CGRectMake(0, originY, self.bounds.size.width, WAWAFOOTVIEWHEIGHT)];
    footRefreshView.startRefreshActionHandler = actionHandler;
    footRefreshView.scrollView = self;
    footRefreshView.backgroundColor = [UIColor redColor];
    [self addSubview:footRefreshView];
    
    self.wawaFootRefresh = footRefreshView;
    self.wawaFootRefresh.footRefreshPosition = position;
    self.isShowFootRefresh = YES;
}


#pragma mark -############################# Setter/Getter #################################################

- (void)setWawaFootRefresh:(WawaFootRefreshView *)wawaFootRefresh
{
    [self willChangeValueForKey:@"WawaFootRefreshView"];
    objc_setAssociatedObject(self, &WawaFootRefreshViewKey, wawaFootRefresh, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"WawaFootRefreshView"];
}

- (WawaFootRefreshView *)wawaFootRefresh
{
    return objc_getAssociatedObject(self, &WawaFootRefreshViewKey);
}

- (void)setIsShowFootRefresh:(BOOL)isShowFootRefresh
{
    [self addObserver:self.wawaFootRefresh forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self.wawaFootRefresh forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

@end


#pragma mark -############################# WawaFootRefreshView ###########################################

@implementation WawaFootRefreshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        (void)self.activityIndicatorView;
    }
    
    return self;
}

- (void)stopAnimation
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint pin =  [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];

        if (pin.y < -WAWAFOOTVIEWHEIGHT)
        {
            return;
        }
        else
        {
            if (_activityIndicatorView)
            {
                [self.activityIndicatorView startAnimating];
            }
        }
        
        NSLog(@" 0000==== point = %@",NSStringFromCGPoint(pin));
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self layoutSubviews];
        
        CGFloat yOrigin = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
        
        [self setFootPosition:yOrigin];
        //        self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
        NSLog(@"------------contsize=%f",yOrigin);
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self layoutSubviews];
    }
}


#pragma mark -############################# Private ###########################################

- (void)layoutSubviews
{
    
}

- (void)setFootPosition:(CGFloat)value
{
    if (self.footRefreshPosition == WawaFootRefreshPositionContentBottom)
    {
        CGRect rect = self.frame;
        rect.origin.y = self.scrollView.contentSize.height;
        self.frame = rect;
    }
    else if (self.footRefreshPosition == WawaFootRefreshPositionScrollViewBottom)
    {
        CGRect rect = self.frame;
        rect.origin.y = CGRectGetHeight(self.scrollView.bounds) - self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
        self.frame = rect;
    }
}


#pragma mark -############################# Setter/Getter #####################################

- (UIActivityIndicatorView *)activityIndicatorView
{
    if(!_activityIndicatorView)
    {
        UIActivityIndicatorView *tempActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        tempActivityIndicatorView.frame = CGRectMake(self.center.x-28.0f/2, 0, 28.0f, 28.0f);
        tempActivityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:tempActivityIndicatorView];
        _activityIndicatorView = tempActivityIndicatorView;
    }
    
    return _activityIndicatorView;
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    return self.activityIndicatorView.activityIndicatorViewStyle;
}


@end
