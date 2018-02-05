//
//  WawaRefresh.h
//  R
//
//  Created by macRong on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "WawaLoadingView.h"
#import "UIScrollView+WawaHeadRefresh.h"
#import "UIScrollView+WawaFootRefresh.h"
#import "UIScrollView+WawaLayout.h"


static const CGFloat WAWALOADINGHEIGHT = 64.0f;



/**
 question:
 
 0. Hidden

 1.快速滑动处理，offset不准
 2.Timer, Runloop
 3.💥时 inset设置生硬
 4. iOS11.0+ loading位置不对
 5. 多次创建 销毁对象
 6. kvo 创建标识销毁
 7. 来回滑动时 wawaLoading有闪动bug
 8. 在下拉loading中，符合上拉条件是否要执行？
 9. Inset 各种情况测试
 10. 下拉大幅度， 松开会导致上拉时间 加判断
 11. 全局设置， 一旦设置全局有效（没有重置情况下） 单利config   // 第2版
 12. 上拉提示‘暂无数据’， 再下拉处理自动除去‘暂无数据’状态
 13. 满足distanceBottom时， foot下滑动，不应响应加载更多
 14. 自定义customView                                  // 第2版
 15. 暴露start loading stop 事件
 16. dragging是💥，不松手如果在满足加载更多条件处理
 17. ContentBottom                                    // 第2版
 18. bottom暂无数据状态时，下拉自动解除bottom暂无状态 ✅
 */


/*
 - (void)setInsetTop:(CGFloat)insetTop{
 UIEdgeInsets inset = self.contentInset;
 inset.top = insetTop;
 if (@available(iOS 11.0, *)) {
 inset.top -= (self.adjustedContentInset.top - self.contentInset.top);
 }
 self.contentInset = inset;
 }
 
 - (CGFloat)insetBottom{
 return self.realContentInset.bottom;
 }
 
 - (void)setInsetBottom:(CGFloat)insetBottom{
 UIEdgeInsets inset = self.contentInset;
 inset.bottom = insetBottom;
 if (@available(iOS 11.0, *)) {
 inset.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom);
 }
 self.contentInset = inset;
 }
 
 - (UIEdgeInsets)realContentInset{
 if (@available(iOS 11.0, *)) {
 return self.adjustedContentInset;
 } else {
 return self.contentInset;
 }
 }
 
 
 */
