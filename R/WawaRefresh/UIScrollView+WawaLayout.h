//
//  UIScrollView+WawaLayout.h
//  R
//
//  Created by macRong on 2018/2/5.
//  Copyright © 2018年 MiaoPai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (WawaLayout)

//@property (nonatomic) CGFloat insetTop;
//@property (nonatomic) CGFloat insetBottom;

@property (assign, readonly) UIEdgeInsets wawa_contentInset;
@property (assign, readonly) UIEdgeInsets wawa_safeContentInsets;


@end
