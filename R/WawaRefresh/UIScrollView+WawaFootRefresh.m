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

#pragma mark -WawaFootRefreshView

@interface WawaFootRefreshView()
{
    CFRunLoopObserverRef _observer;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, copy) dispatch_block_t startRefreshActionHandler;

@property (nonatomic, weak) UILabel *bottomHintLabel;

@property (nonatomic, assign) CGFloat originScroll_BottomInset;
@property (nonatomic, assign, readwrite) BOOL isAnimation;
@property (nonatomic, assign) BOOL isPreDragging;
@property (nonatomic, assign) BOOL isNodata;
@property (nonatomic, assign) BOOL isObserving;


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
//    footRefreshView.backgroundColor = [UIColor redColor];
    [self addSubview:footRefreshView];
    
    self.wawaFootRefresh.originScroll_BottomInset = self.contentInset.bottom;
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
        
        (void)self.activityIndicatorView;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil)
    {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.isShowFootRefresh && self.isObserving)
        {
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"contentSize"];
            self.isObserving = NO;
        }
    }
}


#pragma mark - Out

- (void)startAnimating
{
    self.isNodata = NO;
    
    self.bottomHintLabel.attributedText = self.attributedTitle;
    [self setNeedsLayout];
}

- (void)stopAnimating
{
    self.isPreDragging = self.scrollView.isDragging;

    if (self.activityIndicatorView.isAnimating)
    {
        NSLog(@"+++++++++ stopAnimating");
        [self.activityIndicatorView stopAnimating];
        self.bottomHintLabel.hidden = !self.activityIndicatorView.isAnimating;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // ??????
//            BOOL isAddInset = self.scrollView.contentSize.height >= CGRectGetHeight(self.scrollView.bounds)+self.scrollView.contentInset.bottom;
//            NSLog(@"============isadd222 = %d, ll =%f ,rr=%f",isAddInset,self.scrollView.contentSize.height, CGRectGetHeight(self.scrollView.bounds)+self.scrollView.contentInset.bottom);
//
//
//            if (isAddInset)
//            {
//                if (!con)
//                {
//                    [UIView animateWithDuration:0.2 animations:^{
//
//                        CGRect rec = self.frame;
//                        rec.origin.y = self.scrollView.contentSize.height;
//                        self.frame = rec;
//                        NSLog(@"移动");
//                        UIEdgeInsets contentInset = self.scrollView.contentInset;
//                        contentInset.bottom += WAWAFOOTVIEWHEIGHT;
////                        contentInset.bottom =0;
//                        self.scrollView.contentInset = contentInset;
//                    }];
//                    con = YES;
//                }
//            }
            // ?????
        });

    }
    
    [self setNeedsLayout];
}

- (void)noData:(NSString *)text
{
    self.isNodata = YES;
    WawaPullBomb = NO;
    
    if (self.isAnimation)
    {
        [self stopAnimating];
    }
    
    if (self.bottomHintLabel.isHidden)
    {
        self.bottomHintLabel.hidden = NO;
    }
    
    self.bottomHintLabel.text = text;
    [self setNeedsLayout];
}


#pragma mark - Observer

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
//            NSLog(@"------------contsize=%f",yOrigin);
        }
        else
        {
            CGFloat yOrigin = MIN(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
            [self setFootContentPosition:yOrigin];
//            NSLog(@"------------contsize=%f",yOrigin);
        }
    }
}

- (void)runloopWaitingStateObserve
{
    CFRunLoopRef runLoop = CFRunLoopGetMain();
    CFStringRef runLoopMode = kCFRunLoopDefaultMode;
    
    if (!_observer)
    {
        _observer = CFRunLoopObserverCreateWithHandler(
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
        CFRunLoopAddObserver(runLoop, _observer, runLoopMode);
    }
    else
    {
        BOOL cont = CFRunLoopContainsObserver(runLoop, _observer, runLoopMode);
        if (!cont)
        {
            CFRunLoopAddObserver(runLoop, _observer, runLoopMode);
        }
    }
}

- (void)resetDra
{
    self.isPreDragging = NO;
}


#pragma mark - Private

- (void)scrollViewContentOffsetY:(CGFloat)contentOffsetY
{
//    NSLog(@"contentOffsetY===== %f",contentOffsetY);
    if (contentOffsetY <= -WAWAFOOTVIEWHEIGHT) // ? 要优化
    {
        return;
    }
    
    [self resetValueFromTopBomb];
    
    if (self.scrollView.contentSize.height - fabs(contentOffsetY) - self.scrollView.bounds.size.height <= self.distanceBottom &&
        self.scrollView.isDragging &&
        !self.isPreDragging &&
        !self.isNodata)
    {
        [self runloopWaitingStateObserve];

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
        if (self.attributedTitle && self.attributedTitle.string.length > 0)
        {
            
        }
        self.bottomHintLabel.text = self.attributedTitle.string;
    }
}

- (void)resetScrollViewInsets
{
//    BOOL isAddInset = self.scrollView.contentSize.height >= CGRectGetHeight(self.scrollView.bounds);
//    NSLog(@"============isadd = %d",isAddInset);
//    if (isAddInset)
//    {
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets contentInset = self.scrollView.contentInset;
            contentInset.bottom += WAWAFOOTVIEWHEIGHT;
            self.scrollView.contentInset = contentInset;
        }];
    
    
//    [UIView animateWithDuration:0.2 animations:^{
//        UIEdgeInsets contentInset = self.scrollView.contentInset;
//        contentInset.bottom = self.originScroll_BottomInset + WAWAFOOTVIEWHEIGHT;
//        self.scrollView.contentInset = contentInset;
//    }];
    
    
//    }
//    else
//    {
//        [UIView animateWithDuration:0.2 animations:^{
//            UIEdgeInsets contentInset = self.scrollView.contentInset;
//            contentInset.bottom -= WAWAFOOTVIEWHEIGHT;
//            self.scrollView.contentInset = contentInset;
//        }];
//    }
}

BOOL con ;
- (void)bomb
{
    NSLog(@" 💥 ");
    [self.activityIndicatorView startAnimating];
    self.bottomHintLabel.hidden = !self.activityIndicatorView.isAnimating;
    [self setNeedsLayout];
    
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
        rightBottomLabel.font           = [self wawa_FontOfSize:12.f name:@"PingFangSC-Light"];
        rightBottomLabel.textColor      = [UIColor grayColor];
        [self addSubview:rightBottomLabel];
        _bottomHintLabel = rightBottomLabel;
    }
    
    return _bottomHintLabel;
}


@end
