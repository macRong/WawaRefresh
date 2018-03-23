//
//  UIScrollView+WawaFootRefresh.h
//  R
//
//  Created by 荣守振 on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WawaFootRefreshView;

static const CGFloat WAWAFOOTVIEWHEIGHT = 60.0f;


NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface UIScrollView (WawaFootRefresh)

@property (nonatomic, assign, readonly) BOOL isShowFootRefresh;
@property (nullable, nonatomic, strong, readonly) WawaFootRefreshView *wawaFootRefresh;

- (void)wawaFootRefresh:(dispatch_block_t _Nonnull )actionHandler;

@end

NS_ASSUME_NONNULL_END


/// ------------------------------------------------------------------------------------------------


NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface WawaFootRefreshView: UIView

@property (nonatomic, assign, readonly) BOOL isRefreshing;

- (void)beginRefreshing;
- (void)endRefreshing;
- (void)noData:(NSString *)text;




#pragma mark - Extent(optional)

/** 距离scrollView底部还剩多少距离开始加载. default: 0 .*/
@property (nonatomic, assign) CGFloat distanceBottom;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nullable, nonatomic, strong) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END


