//
//  UIScrollView+WawaLayout.m
//  R
//
//  Created by macRong on 2018/2/5.
//  Copyright © 2018年 MiaoPai. All rights reserved.
//

#import "UIScrollView+WawaLayout.h"

@implementation UIScrollView (WawaLayout)

- (UIEdgeInsets)wawa_contentInset
{
    if (@available(iOS 11.0, *))
    {
        return self.adjustedContentInset;
    }
    else
    {
        return self.contentInset;
    }
}

@end
