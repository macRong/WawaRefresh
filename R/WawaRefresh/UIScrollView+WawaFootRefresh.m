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

#pragma mark -WawaFootRefreshView

@interface WawaFootRefreshView()
{
    CFRunLoopObserverRef observer;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, copy) dispatch_block_t startRefreshActionHandler;

@property (nonatomic, weak) UILabel *bottomHintLabel;

@property (nonatomic, assign, readwrite) BOOL isAnimation;
@property (nonatomic, assign) BOOL isPreDragging;


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
    footRefreshView.backgroundColor = [UIColor redColor];
    [self addSubview:footRefreshView];

    
    self.wawaFootRefresh = footRefreshView;
    self.wawaFootRefresh.footRefreshPosition = position;
    self.isShowFootRefresh = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil)
    {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
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
    [self addObserver:self.wawaFootRefresh forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self.wawaFootRefresh forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
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
        
        (void)self.activityIndicatorView;
    }
    
    return self;
}

#pragma mark - Out

- (void)startAnimating
{
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating
{
    self.isPreDragging = self.scrollView.isDragging;

    if (self.activityIndicatorView.isAnimating)
    {
        NSLog(@"+++++++++ stopAnimating");
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint pin =  [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        [self scrollViewContentOffsetY:pin.y];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self layoutSubviews];
        
        if (self.footRefreshPosition == WawaFootRefreshPositionScrollViewBottom)
        {
            CGFloat yOrigin = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
            [self setFootScrollPosition:yOrigin];
            NSLog(@"------------contsize=%f",yOrigin);
        }
        else
        {
            CGFloat yOrigin = MIN(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
            [self setFootContentPosition:yOrigin];
            NSLog(@"------------contsize=%f",yOrigin);
        }
    }
}


#pragma mark - Private

- (void)scrollViewContentOffsetY:(CGFloat)contentOffsetY
{
    if (contentOffsetY <= -WAWAFOOTVIEWHEIGHT) // ? 要优化
    {
        return;
    }
  
    
    if (self.scrollView.contentSize.height - fabs(contentOffsetY) - self.scrollView.bounds.size.height <= self.distanceBottom && self.scrollView.isDragging && !self.isPreDragging)
    {
        [self runloopWaitingStateObserve];

        if (_activityIndicatorView && !self.activityIndicatorView.isAnimating)
        {
            [self bomb];
        }
    }
}

- (void)resetScrollViewInsets
{
//    BOOL isAddInset = self.scrollView.contentSize.height >= CGRectGetHeight(self.scrollView.bounds);
    [UIView animateWithDuration:0.2 animations:^{
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.bottom += WAWAFOOTVIEWHEIGHT;
        self.scrollView.contentInset = contentInset;
    }];
}

- (void)bomb
{
    NSLog(@" 💥 ");
    
    [self.activityIndicatorView startAnimating];
    if (self.startRefreshActionHandler)
    {
        self.startRefreshActionHandler();
    }
}

- (void)setFootScrollPosition:(CGFloat)value
{
    CGRect rect = self.frame;
    CGFloat sOrigingY = self.scrollView.contentSize.height > CGRectGetHeight(self.scrollView.bounds) ? 0 : self.scrollView.contentInset.top;
    rect.origin.y = value -sOrigingY + self.scrollView.contentInset.bottom /* ? */ - WAWAFOOTVIEWHEIGHT;
    self.frame = rect;
}

- (void)setFootContentPosition:(CGFloat)value
{
    CGRect rect = self.frame;
    rect.origin.y = self.scrollView.contentSize.height /* ? */ - WAWAFOOTVIEWHEIGHT;
    self.frame = rect;
}

- (float)widthForStringHeight:(float)height
{
    CGSize sizeToFit = [self.bottomHintLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(self.activityIndicatorView.bounds),height)];
    
    return sizeToFit.width;
}

- (void)resetDra
{
    self.isPreDragging = NO;
}

- (void)runloopWaitingStateObserve
{
    CFRunLoopRef runLoop = CFRunLoopGetMain();
    CFStringRef runLoopMode = kCFRunLoopDefaultMode;
    
    if (!observer)
    {
        observer = CFRunLoopObserverCreateWithHandler(
                                                      kCFAllocatorDefault, kCFRunLoopBeforeWaiting,
                                                      true,
                                                      0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity)
                                                      {
                                                          if (!self.isAnimation)
                                                          {
                                                              [self performSelectorOnMainThread:@selector(resetDra) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
                                                          }
                                                          else
                                                          {
                                                              CFRunLoopRemoveObserver(runLoop, observer, runLoopMode);
                                                          }
                                                      });
        
        CFRunLoopAddObserver(runLoop, observer, runLoopMode);
    }
    else
    {
        BOOL cont = CFRunLoopContainsObserver(runLoop, observer, runLoopMode);
        if (!cont)
        {
            CFRunLoopAddObserver(runLoop, observer, runLoopMode);
        }
    }
}

- (UIFont *)wawa_FontOfSize:(CGFloat)size name:(NSString *)name
{
    UIFont *font = [UIFont fontWithName:name size:size];
    
    if(font==nil)
    {
        font = [UIFont systemFontOfSize:size];
    }
    
    return font;
}

- (void)layoutSubviews
{
    if (self.attributedTitle && self.attributedTitle.string.length > 0)
    {
        CGFloat widht = [self widthForStringHeight:WAWAFOOTVIEWHEIGHT];
        CGFloat originX = (widht+CGRectGetWidth(self.activityIndicatorView.bounds))/2;
        self.activityIndicatorView.center = CGPointMake(originX,  CGRectGetHeight(self.bounds)/2);
        self.bottomHintLabel.frame = CGRectMake(CGRectGetMaxX(self.activityIndicatorView.frame)+2, 0, widht, CGRectGetHeight(self.bounds));
    }
    else
    {
        self.activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    }
}


#pragma mark -Setter/Getter

- (UIActivityIndicatorView *)activityIndicatorView
{
    if(!_activityIndicatorView)
    {
        UIActivityIndicatorView *tempActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        tempActivityIndicatorView.frame = CGRectMake(self.center.x-28.0f/2, (WAWAFOOTVIEWHEIGHT-28.0f)/2, 28.0f, 28.0f);
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

- (BOOL)isAnimation
{
    return self.activityIndicatorView.isAnimating;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    if (_attributedTitle != attributedTitle)
    {
        _attributedTitle = attributedTitle;
        self.bottomHintLabel.attributedText = _attributedTitle;
        [self setNeedsLayout];
    }
}

- (UILabel *)bottomHintLabel
{
    if (!_bottomHintLabel)
    {
        UILabel *rightBottomLabel       = [[UILabel alloc]init];
        rightBottomLabel.lineBreakMode  = NSLineBreakByTruncatingTail;
        rightBottomLabel.numberOfLines  = 1;
        rightBottomLabel.font           = [self wawa_FontOfSize:12.f name:@"PingFangSC-Light"];
//        rightBottomLabel.textColor      = [UIColor grayColor];
//        rightBottomLabel.text = @"dsdsdsdsds";
        rightBottomLabel.backgroundColor = [UIColor yellowColor];
        [self addSubview:rightBottomLabel];
        _bottomHintLabel = rightBottomLabel;
    }
    
    return _bottomHintLabel;
}


@end
