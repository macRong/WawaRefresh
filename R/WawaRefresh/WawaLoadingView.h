//
//  RView.h
//  R
//
//  Created by macRong on 2018/1/13.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import <UIKit/UIKit.h>


/* Colors. */
struct WaWa_Colors {
    CGFloat  r;
    CGFloat  g;
    CGFloat  b;
};
typedef struct CG_BOXABLE WaWa_Colors WaWa_Colors;


NS_ASSUME_NONNULL_BEGIN
@interface WawaLoadingView : UIView

@property (nonatomic, copy) dispatch_block_t loadingBlock;
@property (nonatomic, assign, readonly) BOOL headLoading;

+ (instancetype)new NS_UNAVAILABLE;

/** @value: 0-12 */
- (void)setLoaingValue:(CGFloat)value;

//- (void)startAnimation:(dispatch_block_t)block;
- (void)stopAnimation;

@end
NS_ASSUME_NONNULL_END


// ?
static const NSInteger WAWALOADINCOUNT   = 12;


id _Nullable wawa_getValidObjectFromArray(NSArray *_Nullable array, NSInteger index);

/** 参考:
 
 CGFloat PreValue = CGFLOAT_MIN;
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
     CGFloat value = scrollView.contentOffset.y;
     if (PreValue == CGFLOAT_MIN)
     {
        PreValue = value;
     }
 
     CGFloat currentHeight = fabs(PreValue - value);
     [_rView setLoaingValue:currentHeight*12/WAWALOADINGHEIGHT];
 }

 */
