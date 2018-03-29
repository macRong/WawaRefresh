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
BOOL WawaPullBomb;

typedef NS_ENUM(NSUInteger, WawaFootRefreshPosition) {
    WawaFootRefreshPositionScrollViewBottom,
};

#pragma mark -WawaFootRefreshView

@interface WawaFootRefreshView()
{
}

@property (nonatomic) WawaFootRefreshPosition footRefreshPosition;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, copy) dispatch_block_t startRefreshActionHandler;

@property (nonatomic, weak) UILabel *bottomHintLabel;

@property (nonatomic, assign) CGFloat originScroll_BottomInset;
@property (nonatomic, assign, readwrite) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isPreDragging;
@property (nonatomic, assign) BOOL isNodata;
@property (nonatomic, assign) BOOL isObserving;

// 加载完成后，是否还满足加载条件
@property (nonatomic, assign) BOOL isPreTracking;


- (void)resetScrollViewInsets;

@end


#pragma mark -UIScrollView+WawaFootRefresh

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
    [self addSubview:footRefreshView];
    
    self.wawaFootRefresh.originScroll_BottomInset = self.wawa_contentInset.bottom;
    self.wawaFootRefresh = footRefreshView;
    self.wawaFootRefresh.footRefreshPosition = position;
    self.isShowFootRefresh = YES;
}


#pragma mark -Setter/Getter

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
    if (!isShowFootRefresh)
    {
        if (self.wawaFootRefresh.isObserving)
        {
            [self removeObserver:self forKeyPath:@"contentOffset"];
            [self removeObserver:self forKeyPath:@"contentSize"];
            self.wawaFootRefresh.isObserving = NO;
        }
    }
    else
    {
        if (!self.wawaFootRefresh.isObserving)
        {
            self.wawaFootRefresh.isObserving = YES;
            [self addObserver:self.wawaFootRefresh forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.wawaFootRefresh forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self.wawaFootRefresh setNeedsLayout];
        }
    }

    [self.wawaFootRefresh resetScrollViewInsets];
}


@end


#pragma mark -WawaFootRefreshView

@implementation WawaFootRefreshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self initVar];
        (void)self.activityIndicatorView;
    }
    
    return self;
}

- (void)initVar
{
    self.isPreTracking = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil)
    {
        UIScrollView *scrollView = (UIScrollView *)self.scrollView;
        if ([scrollView isKindOfClass:[UIScrollView class]] && scrollView.isShowFootRefresh && self.isObserving)
        {
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"contentSize"];
            self.isObserving = NO;
        }
    }
}


#pragma mark - Out

- (void)beginRefreshing
{
    self.isNodata = NO;
    self.isPreTracking = YES;

    self.bottomHintLabel.attributedText = self.attributedTitle;
    [self setNeedsLayout];
}

- (void)endRefreshing
{
    self.isPreDragging = self.scrollView.isDragging;
    self.isPreTracking = self.scrollView.tracking;
    
    if (self.activityIndicatorView.isAnimating)
    {
        [self.activityIndicatorView stopAnimating];
        self.bottomHintLabel.hidden = !self.activityIndicatorView.isAnimating;
    }
    
    [self setNeedsLayout];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"是否依然满足条件+++++++++ stopAnimating= %d",self.scrollView.contentSize.height - fabs(self.scrollView.contentOffset.y) - self.scrollView.bounds.size.height <= self.distanceBottom);
    });
}

- (void)noData:(NSString *)text
{
    self.isNodata = YES;
    WawaPullBomb = NO;
    
    if (self.isRefreshing)
    {
        [self endRefreshing];
    }
    
    if (self.bottomHintLabel.isHidden)
    {
        self.bottomHintLabel.hidden = NO;
    }
    
    self.bottomHintLabel.text = text;
    [self setNeedsLayout];
}


#pragma mark - Private

- (void)resetScOriginY
{
    CGFloat safeHeight = CGRectGetHeight(self.scrollView.bounds)- self.scrollView.wawa_safeContentInsets.top - self.scrollView.wawa_safeContentInsets.bottom ;// - WAWAFOOTVIEWHEIGHT;
    CGRect rect = self.bounds;
    if (self.scrollView.contentSize.height >= safeHeight)
    {
        CGFloat fvalue = self.scrollView.contentSize.height;
        if (fvalue != CGRectGetMinY(rect))
        {
            rect.origin.y = fvalue;
            self.frame = rect;
        }
    }else
    {
        rect.origin.y = safeHeight;
        self.frame = rect;
    }
}

// ????
- (void)scrollViewContentOffsetY:(CGFloat)contentOffsetY
{
//    NSLog(@"====== %d",self.isPreTracking);
    
//    NSLog(@"contentOffsetY===== %f",contentOffsetY);
    if (contentOffsetY <= -WAWAFOOTVIEWHEIGHT) // ? 要优化
    {
        return;
    }

    [self resetValueFromTopBomb];
    
    if (self.scrollView.contentSize.height - fabs(contentOffsetY) - self.scrollView.bounds.size.height <= self.distanceBottom &&
        self.scrollView.isDragging &&
//        !self.isPreDragging &&
//        self.isPreTracking &&
        !self.isRefreshing &&
        !self.isNodata)
    {
        if (_activityIndicatorView && !self.activityIndicatorView.isAnimating)
        {
            [self bomb];
        }
    }
}

- (void)resetValueFromTopBomb
{
    if (WawaPullBomb)
    {
        self.isNodata = !WawaPullBomb;
        self.bottomHintLabel.text = self.attributedTitle.string;
    }
}

- (void)resetScrollViewInsets
{
    [UIView animateWithDuration:0.1 animations:^{
        UIEdgeInsets contentInset = self.scrollView.wawa_contentInset;
        contentInset.bottom += WAWAFOOTVIEWHEIGHT;
        self.scrollView.contentInset = contentInset;
    }];
}

BOOL con ;
- (void)bomb
{
    NSLog(@" 💥 ");
    
    self.isPreTracking = self.scrollView.tracking;
    
    [self.activityIndicatorView startAnimating];
    self.bottomHintLabel.hidden = !self.activityIndicatorView.isAnimating;
    [self setNeedsLayout];
    
    if (self.startRefreshActionHandler)
    {
        self.startRefreshActionHandler();
    }
}

- (void)setFootContentPosition:(CGFloat)value
{
    NSLog(@"====== setFootContentPosition");
    CGRect rect = self.frame;
    rect.origin.y = self.scrollView.contentSize.height /* ? */ - WAWAFOOTVIEWHEIGHT;
    self.frame = rect;
}

- (float)widthForStringHeight:(float)height
{
    CGSize sizeToFit = [self.bottomHintLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(self.activityIndicatorView.bounds),height)];
    return sizeToFit.width;
}

- (UIFont *)wawa_FontOfSize:(CGFloat)size name:(NSString *)name
{
    UIFont *font = [UIFont fontWithName:name size:size];
    
    if(font == nil)
    {
        font = [UIFont systemFontOfSize:size];
    }
    
    return font;
}

- (void)layoutSubviews
{
    CGFloat widht = [self widthForStringHeight:WAWAFOOTVIEWHEIGHT];
 
    [UIView animateWithDuration:0.1f animations:^{
        CGFloat originX = (CGRectGetWidth(self.bounds)-(widht+CGRectGetWidth(self.activityIndicatorView.bounds)+2))/2;
        CGRect activiRect = self.activityIndicatorView.frame;
        activiRect.origin.x =originX;
        self.activityIndicatorView.frame = activiRect;
        
        CGFloat bottomLabelOriginY = self.activityIndicatorView.isHidden ? (CGRectGetWidth(self.bounds) - widht)/2 : CGRectGetMaxX(self.activityIndicatorView.frame)+2 ;
        self.bottomHintLabel.frame = CGRectMake(bottomLabelOriginY, 0, widht, CGRectGetHeight(self.bounds));
    }];
}


#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        
//        NSLog(@"boser contentOffset ===== %d",self.isPreDragging);
        CGPoint pin =  [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        [self scrollViewContentOffsetY:pin.y];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
//        NSLog(@"===== boser contentSize  %d",self.isPreDragging);
        [self layoutSubviews];
        [self resetScOriginY];
    }
}


- (void)resetDra
{
    self.isPreDragging = NO;
}


#pragma mark -Setter/Getter

- (UIActivityIndicatorView *)activityIndicatorView
{
    if(!_activityIndicatorView)
    {
        UIActivityIndicatorView *tempActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        tempActivityIndicatorView.frame = CGRectMake(self.center.x-28.0f/2, (CGRectGetHeight(self.bounds)-28.0f)/2, 28.0f, 28.0f);
        tempActivityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:tempActivityIndicatorView];
        _activityIndicatorView = tempActivityIndicatorView;
    }
    
    return _activityIndicatorView;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    self.activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
}

//- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle
//{
//    return self.activityIndicatorView.activityIndicatorViewStyle;
//}

- (BOOL)isRefreshing
{
    return self.activityIndicatorView.isAnimating;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    if (_attributedTitle != attributedTitle)
    {
        _attributedTitle = attributedTitle;
        self.bottomHintLabel.attributedText = _attributedTitle;
    }
    
    [self setNeedsLayout];
}

- (UILabel *)bottomHintLabel
{
    if (!_bottomHintLabel)
    {
        UILabel *rightBottomLabel       = [[UILabel alloc]init];
        rightBottomLabel.lineBreakMode  = NSLineBreakByTruncatingTail;
        rightBottomLabel.numberOfLines  = 1;
        rightBottomLabel.font           = [self wawa_FontOfSize:13.f name:@"PingFangSC-Light"];
        rightBottomLabel.textColor      = [UIColor grayColor];
        [self addSubview:rightBottomLabel];
        _bottomHintLabel = rightBottomLabel;
    }
    
    return _bottomHintLabel;
}


@end
