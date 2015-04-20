//
//  UIScrollView+PullRefresh.h
//  testPullRefresh
//
//  Created by yangjh on 14-7-17.
//  Copyright (c) 2014年 yjh4866. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RefreshView : UIView
@property (nonatomic, readonly) UILabel *labelStatus;
@property (nonatomic, readonly) UILabel *labelLastUpdateTime;
@property (nonatomic, readonly) UIImageView *imageViewArrow;
@end


// 开始刷新的block定义
typedef void (^StartRefreshing)(UIScrollView *scrollView);
// 停止刷新的动画结束的block定义
typedef void (^FinishRefreshing)(UIScrollView *scrollView);


@interface UIScrollView (PullRefresh)

// 显示下拉刷新
- (RefreshView *)showHeaderRefresh;

// 移除下拉刷新
- (void)removeHeaderRefresh;

// 显示上拉加载
- (RefreshView *)showFooterRefresh;

// 移除上拉加载
- (void)removeFooterRefresh;

// 设置下拉开始刷新时的block
- (void)setStartBlockOfHeaderRefresh:(StartRefreshing)headerStartRefresh;

// 设置结束下拉刷新动画完成时的block
- (void)setFinishBlockOfHeaderRefresh:(StartRefreshing)headerFinishRefresh;

// 设置上拉开始刷新时的block
- (void)setStartBlockOfFooterRefresh:(StartRefreshing)footerStartRefresh;

// 设置结束上拉刷新动画完成时的block
- (void)setFinishBlockOfFooterRefresh:(StartRefreshing)footerFinishRefresh;

// 开始下拉刷新
- (void)startHeaderRefresh;

// 结束下拉刷新
- (void)endHeaderRefresh;

// 开始上拉加载
- (void)startFooterRefresh;

// 结束上拉加载
- (void)endFooterRefresh;

@end
