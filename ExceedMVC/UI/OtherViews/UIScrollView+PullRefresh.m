//
//  UIScrollView+PullRefresh.m
//  testPullRefresh
//
//  Created by yangjh on 14-7-17.
//  Copyright (c) 2014年 yjh4866. All rights reserved.
//

#import "UIScrollView+PullRefresh.h"

// 刷新视图的高度
#define Height_RefreshView         64.0f
// 动画时长
#define AnimateDuration_CSRefresh    0.25f
//
#define KVOKeyPath_CSRefreshContentOffset   @"contentOffset"

#pragma mark - RefreshView

typedef NS_ENUM(unsigned int, RefreshViewStatus) {
    RefreshViewStatus_Normal,
    RefreshViewStatus_Pulling,
    RefreshViewStatus_Refreshing,
};

@interface RefreshView ()
@property (nonatomic, assign) BOOL isHeaderRefresh; // 是否为头部刷新视图
#if __has_feature(objc_arc)
@property (nonatomic, strong) UILabel *labelStatus;
@property (nonatomic, strong) UILabel *labelLastUpdateTime;
@property (nonatomic, strong) UIImageView *imageViewArrow;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) StartRefreshing startRefreshing;
@property (nonatomic, strong) FinishRefreshing finishRefreshing;
@property (nonatomic, strong) NSDate *dateRefresh;
#else
@property (nonatomic, retain) UILabel *labelStatus;
@property (nonatomic, retain) UILabel *labelLastUpdateTime;
@property (nonatomic, retain) UIImageView *imageViewArrow;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, copy) StartRefreshing startRefreshing;
@property (nonatomic, copy) FinishRefreshing finishRefreshing;
@property (nonatomic, retain) NSDate *dateRefresh;
#endif
@property (nonatomic, readonly) BOOL dragRefresh;
@property (nonatomic, readonly) BOOL refreshing;
@property (nonatomic, assign) RefreshViewStatus refreshStatus;
@end

@implementation RefreshView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0xea/255.0f alpha:1.0];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIColor *clrLabel = [UIColor colorWithWhite:150/255.0f alpha:1.0f];
        // 状态标签
        UILabel *labelStatus = [[UILabel alloc] initWithFrame:CGRectZero];
        labelStatus.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        labelStatus.font = [UIFont boldSystemFontOfSize:13];
        labelStatus.textColor = clrLabel;
        labelStatus.backgroundColor = [UIColor clearColor];
        labelStatus.textAlignment = NSTextAlignmentCenter;
        [self addSubview:labelStatus];
        self.labelStatus = labelStatus;
        // 上次更新时间的标签
        UILabel *labelLastUpdateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        labelLastUpdateTime.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        labelLastUpdateTime.font = [UIFont boldSystemFontOfSize:12];
        labelLastUpdateTime.textColor = clrLabel;
        labelLastUpdateTime.backgroundColor = [UIColor clearColor];
        labelLastUpdateTime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:labelLastUpdateTime];
        self.labelLastUpdateTime = labelLastUpdateTime;
        // 箭头
        UIImageView *imageViewArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageViewArrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:imageViewArrow];
        self.imageViewArrow = imageViewArrow;
        // 指示器
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = imageViewArrow.bounds;
        activityView.autoresizingMask = imageViewArrow.autoresizingMask;
        [self addSubview:activityView];
        self.activityView = activityView;
        // 统一释放
#if __has_feature(objc_arc)
#else
        [labelStatus release];
        [labelLastUpdateTime release];
        [imageViewArrow release];
        [activityView release];
#endif
        _dragRefresh = NO;
        _refreshing = NO;
        _labelLastUpdateTime.text = @"";
        [self addObserver:self forKeyPath:@"self.isHeaderRefresh"
                  options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"self.refreshStatus"
                  options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
    frame.size.height = Height_RefreshView;
    super.frame = frame;
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.isHeaderRefresh"];
    [self removeObserver:self forKeyPath:@"self.refreshStatus"];
    //
    self.startRefreshing = nil;
    self.finishRefreshing = nil;
    self.labelStatus = nil;
    self.labelLastUpdateTime = nil;
    self.imageViewArrow = nil;
    self.activityView = nil;
    self.startRefreshing = nil;
    self.finishRefreshing = nil;
    self.dateRefresh = nil;
#if __has_feature(objc_arc)
#else
    [super dealloc];
#endif
}
- (void)layoutSubviews
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    if (self.isHeaderRefresh) {
        self.labelStatus.frame = CGRectMake(0, 10, width, 20);
        self.labelLastUpdateTime.frame = CGRectMake(0, 10+20+5, width, 20);
    }
    else {
        self.labelStatus.frame = self.bounds;
        self.labelLastUpdateTime.frame = CGRectZero;
    }
    CGSize sizeArrow = self.imageViewArrow.image.size;
    self.imageViewArrow.frame = CGRectMake((width-sizeArrow.width)/2-100, (height-sizeArrow.height)/2,
                                           sizeArrow.width, sizeArrow.height);
    self.activityView.center = self.imageViewArrow.center;
}
- (void)removeFromSuperview
{
    self.startRefreshing = nil;
    self.finishRefreshing = nil;
    [super removeFromSuperview];
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"self.isHeaderRefresh"]) {
        self.refreshStatus = self.refreshStatus;
    }
    else if ([keyPath isEqualToString:@"self.refreshStatus"]) {
        switch (self.refreshStatus) {
            case RefreshViewStatus_Normal:
            {
                _refreshing = NO;
                _dragRefresh = NO;
                self.imageViewArrow.hidden = NO;
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
                if (self.isHeaderRefresh) {
                    self.labelStatus.text = @"下拉可以刷新";
                    self.imageViewArrow.transform = CGAffineTransformIdentity;
                }
                else {
                    self.labelStatus.text = @"上拉可以加载更多数据";
                    self.imageViewArrow.transform = CGAffineTransformMakeRotation(M_PI);
                }
            }
                break;
            case RefreshViewStatus_Pulling:
            {
                _refreshing = NO;
                _dragRefresh = YES;
                self.imageViewArrow.hidden = NO;
                self.activityView.hidden = YES;
                if (self.isHeaderRefresh) {
                    self.labelStatus.text = @"松开立即刷新";
                    self.imageViewArrow.transform = CGAffineTransformMakeRotation(M_PI);
                }
                else {
                    self.labelStatus.text = @"松开立即加载更多数据";
                    self.imageViewArrow.transform = CGAffineTransformIdentity;
                }
            }
                break;
            case RefreshViewStatus_Refreshing:
            {
                _refreshing = YES;
                _dragRefresh = NO;
                self.imageViewArrow.hidden = YES;
                self.activityView.hidden = NO;
                if (self.isHeaderRefresh) {
                    self.labelStatus.text = @"正在刷新...";
                    [self.activityView startAnimating];
                }
                else {
                    self.labelStatus.text = @"正在加载数据...";
                    [self.activityView startAnimating];
                }
            }
                break;
            default:
                break;
        }
    }
}
@end


#pragma mark - UIScrollView (PullRefresh)

@implementation UIScrollView (PullRefresh)

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KVOKeyPath_CSRefreshContentOffset]) {
        if (self.isDragging) {
            // 下拉
            if (self.contentOffset.y < 0) {
                // 有下拉刷新视图
                RefreshView *refreshView = [self getHeaderRefreshView];
                if (refreshView && !refreshView.refreshing) {
                    // 显示更新时间
                    [self updateRefreshTimeOf:refreshView];
                    // 下拉到指定尺度时需要旋转箭头
                    if (self.contentOffset.y <= -Height_RefreshView) {
                        [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
                            refreshView.refreshStatus = RefreshViewStatus_Pulling;
                        }];
                    }
                    else {
                        [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
                            refreshView.refreshStatus = RefreshViewStatus_Normal;
                        }];
                    }
                }
            }
            // 上拉
            else {
                // 上拉有效
                CGFloat topOri = MAX(self.contentSize.height-self.bounds.size.height, 0);
                if (self.contentOffset.y > topOri) {
                    // 有上拉加载视图
                    RefreshView *refreshView = [self getFooterRefreshView];
                    if (refreshView && !refreshView.refreshing) {
                        // 上拉到指定尺度时需要旋转箭头
                        if (self.contentOffset.y >= topOri+Height_RefreshView) {
                            [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
                                refreshView.refreshStatus = RefreshViewStatus_Pulling;
                            }];
                        }
                        else {
                            [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
                                refreshView.refreshStatus = RefreshViewStatus_Normal;
                            }];
                        }
                    }
                }
            }
        }
        else {
            // 下拉
            if (self.contentOffset.y < 0) {
                // 有下拉刷新视图且为下拉状态
                RefreshView *refreshView = [self getHeaderRefreshView];
                if (refreshView && RefreshViewStatus_Pulling==refreshView.refreshStatus) {
                    [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
                        //
                        UIEdgeInsets inset = self.contentInset;
                        inset.top = Height_RefreshView;
                        self.contentInset = inset;
                        //
                        if (refreshView.dragRefresh) {
                            refreshView.refreshStatus = RefreshViewStatus_Refreshing;
                            if (refreshView.startRefreshing) {
                                refreshView.startRefreshing(self);
                            }
                        }
                    }];
                }
            }
            // 上拉
            else {
                // 有上拉加载视图且为上拉状态
                RefreshView *refreshView = [self getFooterRefreshView];
                if (refreshView && RefreshViewStatus_Pulling==refreshView.refreshStatus) {
                    [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
                        UIEdgeInsets inset = self.contentInset;
                        if (self.contentSize.height > self.bounds.size.height) {
                            inset.bottom = Height_RefreshView;
                        }
                        else {
                            inset.bottom = self.bounds.size.height-self.contentSize.height+Height_RefreshView;
                        }
                        self.contentInset = inset;
                        //
                        if (refreshView.dragRefresh) {
                            refreshView.refreshStatus = RefreshViewStatus_Refreshing;
                            if (refreshView.startRefreshing) {
                                refreshView.startRefreshing(self);
                            }
                        }
                    }];
                }
            }
        }
        // 如果上拉加载存在，则再次显示上拉加载以更新位置
        if ([self getFooterRefreshView]) {
            [self showFooterRefresh];
        }
    }
}

#pragma mark Public

// 显示下拉刷新
- (RefreshView *)showHeaderRefresh
{
    CGRect frameRefresh = CGRectMake(0, -Height_RefreshView,
                                     self.bounds.size.width, Height_RefreshView);
    RefreshView *headerRefreshView = [self getHeaderRefreshView];
    if (headerRefreshView) {
        headerRefreshView.frame = frameRefresh;
        return headerRefreshView;
    }
    // 创建下拉刷新
    headerRefreshView = [[RefreshView alloc] initWithFrame:frameRefresh];
    headerRefreshView.isHeaderRefresh = YES;
    [self addSubview:headerRefreshView];
#if __has_feature(objc_arc)
#else
    [headerRefreshView release];
#endif
    
    // 监听contentOffset
    [self addObserver:self forKeyPath:KVOKeyPath_CSRefreshContentOffset
              options:NSKeyValueObservingOptionNew context:nil];
    return headerRefreshView;
}

// 移除下拉刷新
- (void)removeHeaderRefresh
{
    RefreshView *refreshView = [self getHeaderRefreshView];
    if (refreshView) {
        refreshView.startRefreshing = nil;
        refreshView.finishRefreshing = nil;
        [refreshView removeFromSuperview];
        // 移除拉动时的监听器
        [self removeObserver:self forKeyPath:KVOKeyPath_CSRefreshContentOffset];
    }
}

// 显示上拉加载
- (RefreshView *)showFooterRefresh
{
    CGFloat topRefresh = MAX(self.contentSize.height, self.bounds.size.height);
    CGRect frameRefresh = CGRectMake(0, topRefresh, self.bounds.size.width, Height_RefreshView);
    RefreshView *footerRefreshView = [self getFooterRefreshView];
    if (footerRefreshView) {
        footerRefreshView.frame = frameRefresh;
        return footerRefreshView;
    }
    // 创建上拉加载
    footerRefreshView = [[RefreshView alloc] initWithFrame:frameRefresh];
    footerRefreshView.isHeaderRefresh = NO;
    [self addSubview:footerRefreshView];
#if __has_feature(objc_arc)
#else
    [footerRefreshView release];
#endif
    
    // 监听contentOffset
    [self addObserver:self forKeyPath:KVOKeyPath_CSRefreshContentOffset
              options:NSKeyValueObservingOptionNew context:nil];
    return footerRefreshView;
}

// 移除上拉加载
- (void)removeFooterRefresh
{
    RefreshView *refreshView = [self getFooterRefreshView];
    if (refreshView) {
        refreshView.startRefreshing = nil;
        refreshView.finishRefreshing = nil;
        [refreshView removeFromSuperview];
        // 移除拉动时的监听器
        [self removeObserver:self forKeyPath:KVOKeyPath_CSRefreshContentOffset];
    }
}

// 设置下拉开始刷新时的block
- (void)setStartBlockOfHeaderRefresh:(StartRefreshing)headerStartRefresh
{
    [self getHeaderRefreshView].startRefreshing = headerStartRefresh;
}

// 设置结束下拉刷新动画完成时的block
- (void)setFinishBlockOfHeaderRefresh:(StartRefreshing)headerFinishRefresh
{
    [self getHeaderRefreshView].finishRefreshing = headerFinishRefresh;
}

// 设置上拉开始刷新时的block
- (void)setStartBlockOfFooterRefresh:(StartRefreshing)footerStartRefresh
{
    [self getFooterRefreshView].startRefreshing = footerStartRefresh;
}

// 设置结束上拉刷新动画完成时的block
- (void)setFinishBlockOfFooterRefresh:(StartRefreshing)footerFinishRefresh
{
    [self getFooterRefreshView].finishRefreshing = footerFinishRefresh;
}

// 开始下拉刷新
- (void)startHeaderRefresh
{
    RefreshView *refreshView = [self getHeaderRefreshView];
    if (refreshView && !refreshView.refreshing) {
        refreshView.refreshStatus = RefreshViewStatus_Pulling;
        // 执行动画
        [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
            //
            UIEdgeInsets inset = self.contentInset;
            inset.top = Height_RefreshView;
            self.contentInset = inset;
            // 下拉
            self.contentOffset = CGPointMake(0, -Height_RefreshView);
        }];
    }
}

// 结束下拉刷新
- (void)endHeaderRefresh
{
    RefreshView *refreshView = [self getHeaderRefreshView];
    if (refreshView && refreshView.refreshing) {
        refreshView.dateRefresh = [NSDate date];
        // 动画缩回去
        refreshView.refreshStatus = RefreshViewStatus_Normal;
        [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
            refreshView.refreshStatus = RefreshViewStatus_Normal;
            //
            UIEdgeInsets inset = self.contentInset;
            inset.top = 0.0f;
            self.contentInset = inset;
            // block通知
            if (refreshView.finishRefreshing) {
                [self performSelector:@selector(headerRefreshingFinishForPerform:)
                           withObject:refreshView afterDelay:0.1f];
            }
        }];
    }
}

// 开始上拉加载
- (void)startFooterRefresh
{
    RefreshView *refreshView = [self getFooterRefreshView];
    if (refreshView && !refreshView.refreshing) {
        refreshView.refreshStatus = RefreshViewStatus_Pulling;
        // 执行动画
        [UIView animateWithDuration:AnimateDuration_CSRefresh animations:^{
            //
            UIEdgeInsets inset = self.contentInset;
            if (self.contentSize.height > self.bounds.size.height) {
                inset.bottom = Height_RefreshView;
            }
            else {
                inset.bottom = self.bounds.size.height-self.contentSize.height+Height_RefreshView;
            }
            self.contentInset = inset;
            // 上拉
            self.contentOffset = CGPointMake(0, inset.bottom-(self.bounds.size.height-self.contentSize.height));
        }];
    }
}

// 结束上拉加载
- (void)endFooterRefresh
{
    RefreshView *refreshView = [self getFooterRefreshView];
    if (refreshView && refreshView.refreshing) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, AnimateDuration_CSRefresh*NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            refreshView.refreshStatus = RefreshViewStatus_Normal;
            //
            UIEdgeInsets inset = self.contentInset;
            inset.bottom = 0.0f;
            self.contentInset = inset;
            // block通知
            if (refreshView.finishRefreshing) {
                [self performSelector:@selector(footerRefreshingFinishForPerform:)
                           withObject:refreshView afterDelay:0.1f];
            }
        });
    }
}


#pragma mark Private

// 获取下拉刷新视图
- (RefreshView *)getHeaderRefreshView
{
    // 下拉刷新已经存在则不做处理
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:RefreshView.class] &&
            ((RefreshView*)subview).isHeaderRefresh) {
            return (RefreshView*)subview;
        }
    }
    return nil;
}
// 获取上拉加载视图
- (RefreshView *)getFooterRefreshView
{
    // 下拉刷新已经存在则不做处理
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:RefreshView.class] &&
            !((RefreshView*)subview).isHeaderRefresh) {
            return (RefreshView*)subview;
        }
    }
    return nil;
}

- (void)headerRefreshingFinishForPerform:(RefreshView *)refreshView
{
    refreshView.refreshStatus = RefreshViewStatus_Normal;
    refreshView.finishRefreshing(self);
}

- (void)footerRefreshingFinishForPerform:(RefreshView *)refreshView
{
    refreshView.refreshStatus = RefreshViewStatus_Normal;
    refreshView.finishRefreshing(self);
}

- (void)updateRefreshTimeOf:(RefreshView *)refreshView
{
    if (nil == refreshView.dateRefresh) {
        return;
    }
    // 解析
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:refreshView.dateRefresh];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day]==[cmp2 day] && [cmp1 month]==[cmp2 month] && [cmp1 year]==[cmp2 year]) { // 年月日均相等
        formatter.dateFormat = @"今天 HH:mm";
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    NSString *time = [formatter stringFromDate:refreshView.dateRefresh];
#if __has_feature(objc_arc)
#else
    [formatter release];
#endif
    
    // 3.显示日期
    refreshView.labelLastUpdateTime.text = [NSString stringWithFormat:@"最后更新：%@", time];
}

@end
