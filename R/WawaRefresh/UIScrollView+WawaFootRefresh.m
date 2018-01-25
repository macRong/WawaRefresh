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

@property (nonatomic, copy) dispatch_block_t startRefreshActionHandler;

@end

#pragma mark -############################# UIScrollView+WawaFootRefresh ##################################

@implementation UIScrollView (WawaFootRefresh)
@dynamic wawaFootRefresh;

- (void)wawaFootRefresh:(dispatch_block_t)actionHandler
{
    [self wawaFootRefreshWithpostion:WawaFootRefreshPositionScrollViewBottom actionHandler:actionHandler];
}

- (void)wawaFootRefreshWithpostion:(WawaFootRefreshPosition)position actionHandler:(dispatch_block_t)actionHandler
{
    WawaFootRefreshView *footRefreshView = [[WawaFootRefreshView alloc]initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, WAWAFOOTVIEWHEIGHT)];
    footRefreshView.startRefreshActionHandler = actionHandler;
    footRefreshView.scrollView = self;
    footRefreshView.backgroundColor = [UIColor redColor];
    [self addSubview:footRefreshView];
}


#pragma mark -############################# Setter/Getter #################################################

- (void)setWawaFootRefresh:(WawaFootRefreshView *)wawaFootRefresh
{
    [self willChangeValueForKey:@"WawaFootRefreshView"];
    objc_setAssociatedObject(self, &WawaFootRefreshViewKey, wawaFootRefresh, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"WawaFootRefreshView"];
}

- (WawaHeadRefreshView *)wawaHeadRefresh
{
    return objc_getAssociatedObject(self, &WawaFootRefreshViewKey);
}

@end


#pragma mark -############################# WawaFootRefreshView ###########################################

@implementation WawaFootRefreshView

- (void)stopAnimation
{
    
}

@end
