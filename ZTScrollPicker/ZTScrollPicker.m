//
//  ZTScrollPicker.m
//  ZTScrollPicker
//
//  Created by 谢展图 on 15/8/2.
//  Copyright (c) 2015年 spice. All rights reserved.
//
#define KviewStroe 5

#import "ZTScrollPicker.h"


@interface ZTScrollPicker (){
    bool snapping;
    float lastSnappingX;
    UIView *selectBiggestView;
}

@property (nonatomic,strong) NSMutableArray *viewStroe;
//@property (nonatomic,strong)


@end

@implementation ZTScrollPicker

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetting];
    }
    return self;
}

// TODO initwithviews
- (instancetype)initWithFrame:(CGRect)frame views:(NSArray *)views{
    return self;
}

- (instancetype)initWithImages:(NSArray *)images imageSize:(CGSize )imageSize{
    self = [super init];
    if (self) {
        self.viewSize = imageSize;
        self.imageArray = images;
        
        [self initSetting];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame Images:(NSArray *)images imageSize:(CGSize )imageSize titles:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewSize = imageSize;
        self.imageArray = images;
        self.titleArray = titles;
        
        [self initSetting];
        [self initBudilScroll];
    }
    return self;
};

- (void)initSetting{
    
    _alphaOfobjs = 1.0;
    _heightOffset = 0.0;
    _positionRatio = 1.0;
    
    _viewMargin = 0;
    _viewCount = 1;
    
    self.contentSize = self.frame.size;
    self.pagingEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;

}

- (void)initBudilScroll{
    
    if (self.viewSize.width == 0 && self.viewSize.height == 0) {
        if (self.imageArray.count > 0) self.viewSize = [(UIImage *)[self.imageArray objectAtIndex:0] size];
        else self.viewSize = CGSizeMake(self.frame.size.height/2, self.frame.size.height/2);
    }
    
    int stores = 5;
    if (self.imageArray.count>0) {
        for (int i = 0; i<self.imageArray.count*stores; i++) {

            id obj = self.imageArray[i%self.imageArray.count];
            UIImage *image  = nil;
            if ([obj isKindOfClass:[UIImage class]]) {
                image = (UIImage *)obj;
            }else if([obj isKindOfClass:[NSURL class]]){
                // TODO 异步加载图片
//                NSURL *url =(NSURL *)obj;
//                [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"CollectionCellDefault"]];
            }
            else{
                UIImageView *iv = (UIImageView *)obj;
                image = iv.image;
            }
           
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.viewSize.width+_viewMargin, self.frame.size.height - self.viewSize.height, self.viewSize.width, self.viewSize.height)];
            [imageView setImage:image];
            [imageView setTag:i%self.imageArray.count+100];
            
            // TODO title
            if (self.titleArray.count>0) {
                
                //            //  创建需要的毛玻璃特效类型
                //            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                //            //  毛玻璃view 视图
                //            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                //            //添加到要有毛玻璃特效的控件中
                //            effectView.frame = imageView.bounds;
                //            [imageView addSubview:effectView];
                //            //设置模糊透明度
                //            effectView.alpha = .7f;
                
                //            UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.viewSize.height-30, self.viewSize.width, 30)];
                //            [bottomView setBackgroundColor:[UIColor blackColor]];
                //            [imageView addSubview:bottomView];
                
            }
            
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClicked:)];
            [imageView addGestureRecognizer:tapGesture];
            
            [self.viewStroe addObject:imageView];
            [self addSubview:imageView];
        }
        
    }
    
    self.contentSize = CGSizeMake(self.imageArray.count * 5 * self.viewSize.width, self.frame.size.height);
    
    float viewMiddle = self.imageArray.count * 2 * self.viewSize.width;
    [self setContentOffset:CGPointMake(viewMiddle, 0)];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^ {
        [self reloadView:viewMiddle-10];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self snapToAnEmotion];
        });
    });
   
    // TODO customView
    //    if (_customViewsCount>0) {
    //        for (int i = 0; i<_customViewsCount; i++) {
    //            UIView *view = self.customViewAtIndex(i);
    //            [self.customViewStroe addObject:view];
    //        }
    //    }
    
}
- (void)layoutIfNeeded{
    [super layoutIfNeeded];
    NSLog(@"layoutIfNeeded");
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.contentOffset.x > 0)
    {
        float sectionSize = self.imageArray.count * (self.viewSize.width+_viewMargin) - _viewMargin;
        
        if (self.contentOffset.x <= sectionSize/2)
        {
            self.contentOffset = CGPointMake(sectionSize * 2 - sectionSize/2+_viewMargin, 0);
        } else if (self.contentOffset.x >= (sectionSize * 3 + sectionSize/2)) {
            self.contentOffset = CGPointMake(sectionSize * 2 + sectionSize/2-_viewMargin, 0);
        }
        
        [self reloadView:self.contentOffset.x];
    }
}


- (void)reloadView:(float)offset{
    
    float biggestSize = 0;
    id biggestView;
    
    for (int i = 0 ; i<self.viewStroe.count; i++) {
        UIView *view = [self.viewStroe objectAtIndex:i];
        
        //屏幕内
        if (view.center.x > (offset - self.viewSize.width ) && view.center.x < (offset + self.frame.size.width + self.viewSize.width))
        {
            
            float tOffset = (view.center.x - offset) - self.frame.size.width/4;
            
            if (tOffset < 0 || tOffset > self.frame.size.width) tOffset = 0;
            float addHeight = (-1 * fabs((tOffset)*2 - self.frame.size.width/2) + self.frame.size.width/2)/4;
            if (addHeight < 0) addHeight = 0;
            
            view.frame = CGRectMake(view.frame.origin.x,
                                    self.frame.size.height - self.viewSize.height - _heightOffset - (addHeight/_positionRatio),
                                    self.viewSize.width + addHeight,
                                    self.viewSize.height + addHeight);
            
            if (((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x) > biggestSize)
            {
                biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x);
                biggestView = view;
            }
            
        } else {
            // ????
            view.frame = CGRectMake(view.frame.origin.x, self.frame.size.height, self.viewSize.width, self.viewSize.height);
            for (UIImageView *imageView in view.subviews)
            {
                imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            }
        }

        //修改变大图片间距
        for (int i = 0; i < self.viewStroe.count; i++)
        {
            UIView *cBlock = [self.viewStroe objectAtIndex:i];
            cBlock.alpha = _alphaOfobjs;
            
            if (i > 0)
            {
                UIView *pBlock = [self.viewStroe objectAtIndex:i-1];
                if (i-1 ==0) {
                    cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width , cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height);
                }else{
                    cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width + _viewMargin, cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height);
                }
                
            }
        }
        
        [(UIView *)biggestView setAlpha:1.0];
    }
}

#pragma mark private
- (void)snapToAnEmotion
{
    float biggestSize = 0;
//    UIImageView *biggestView;
    
    snapping = YES;
    
    float offset = self.contentOffset.x;
    
    for (int i = 0; i < self.viewStroe.count; i++) {
        UIImageView *view = [ self.viewStroe objectAtIndex:i];
        
        //屏幕内 显示大于一半的
        if (view.center.x > offset && view.center.x < (offset + self.frame.size.width))
        {
            //最大的一个
            if (view.frame.size.width > biggestSize)
            {
                biggestSize =  view.frame.size.width;
                selectBiggestView = view;
            }
            
        }
    }
    
    float biggestViewX = selectBiggestView.frame.origin.x + selectBiggestView.frame.size.width/2 - self.frame.size.width/2;
    float dX = self.contentOffset.x - biggestViewX;
    
    float newX = 0 ;
    if (dX<0) {
        newX = self.contentOffset.x - (dX*1.8/1.4);
    }
    else{
        newX = self.contentOffset.x - dX/1.4;
    }
    
    // Disable scrolling when snapping to new location
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^ {
        [self setScrollEnabled:NO];
        [self scrollRectToVisible:CGRectMake(newX, 0, self.frame.size.width, 1) animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            // TODO performSelector:selector
            if (self.currentSelectBlock) {
                self.currentSelectBlock(selectBiggestView.tag);
            }
            
            [self setScrollEnabled:YES];
            snapping = 0;
        });
    });
}



#pragma mark ScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == 0 && !snapping) [self snapToAnEmotion];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!snapping) [self snapToAnEmotion];
}

#pragma mark Gesture Recogizner Delegate
- (void)viewClicked:(id)sender{
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    if (singleTap.view.tag != selectBiggestView.tag) {
        float selectviewx = singleTap.view.frame.origin.x + singleTap.view.frame.size.width/2 - self.frame.size.width/2;
        float dX = self.contentOffset.x - selectviewx;
        float newX = self.contentOffset.x - dX/1.4;
        
        if (dX<0) {
            newX  = newX + self.viewMargin+10;
        }
        else{
            
            newX  = newX - self.viewMargin-10;
        }
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^ {
            [self setScrollEnabled:NO];
            [self scrollRectToVisible:CGRectMake(newX, 0, self.frame.size.width, 1) animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self setScrollEnabled:YES];
                selectBiggestView = singleTap.view;
            });
        });
        
    }else{
        if (self.clickblock) {
            self.clickblock(singleTap.view.tag-100);
        }
    }
}

#pragma mark get/set

- (void)setCustomViewAtIndex:(customViewAtIndex)customViewAtIndex{
    
}


- (void)setViewCount:(NSUInteger)viewCount{
    _viewCount = viewCount;
    [self initBudilScroll];
}

- (NSArray *)customView{
    if (!_customView) {
        _customView = [[NSArray alloc]init];
    }
    
    [self initBudilScroll];
    return _customView;
}
- (NSArray *)customViewStroe{
    if (!_viewStroe) {
        _viewStroe = [[NSMutableArray alloc]init];
    }
    return _viewStroe;
}
- (NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = [[NSMutableArray alloc]init];
    }
    return _titleArray;
}
- (NSArray *)imageArray{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc]init];
    }
    return _imageArray;
}

- (NSMutableArray *)viewStroe{
    if (!_viewStroe) {
        _viewStroe = [[NSMutableArray alloc]init];
    }
    return _viewStroe;
}

- (void)setDefaultViewIndex:(NSUInteger)defaultViewIndex{
    _defaultViewIndex = defaultViewIndex;
    if (defaultViewIndex<self.imageArray.count) {
        
    }
}
@end
