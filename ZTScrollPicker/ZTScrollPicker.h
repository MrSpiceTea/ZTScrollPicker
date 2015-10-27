//
//  ZTScrollPicker.h
//  ZTScrollPicker
//
//  Created by 谢展图 on 15/8/2.
//  Copyright (c) 2015年 spice. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZTScrollPickerStyle){
    ZTScrollPickerStyleCustomViews ,
    ZTScrollPickerStyleImages ,
};


@interface ZTScrollPicker : UIScrollView<UIScrollViewDelegate>

typedef void (^currentSelectBlock)(NSInteger tag);
typedef void (^clickBlock)(NSInteger tag);
typedef UIView *(^customViewAtIndex)(NSInteger index);

@property (nonatomic,assign) float viewMargin;
@property (nonatomic,assign) CGSize viewSize;
@property (nonatomic,assign) NSUInteger viewCount;
@property (nonatomic,assign) NSUInteger defaultViewIndex;
@property (nonatomic,strong) NSArray *customView;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *titleArray;

@property (nonatomic) float alphaOfobjs;
@property (nonatomic) float heightOffset;
@property (nonatomic) float positionRatio;


@property (nonatomic,copy) customViewAtIndex customViewAtIndex;
@property (nonatomic,copy) clickBlock clickblock;
@property (nonatomic,copy) currentSelectBlock currentSelectBlock;


- (instancetype)initWithFrame:(CGRect)frame Images:(NSArray *)images imageSize:(CGSize )imageSize titles:(NSArray *)titles;
@end
