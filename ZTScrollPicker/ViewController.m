//
//  ViewController.m
//  ZTScrollPicker
//
//  Created by 谢展图 on 15/8/2.
//  Copyright (c) 2015年 spice. All rights reserved.
//

#import "ViewController.h"
#import "ZTScrollPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *set1 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 6; i++) {

        [set1 addObject:[ [UIImageView alloc]initWithImage:[UIImage imageNamed:@"1.png"]]];
    }
    
    
    ZTScrollPicker *ztsp = [[ZTScrollPicker alloc] initWithFrame:CGRectMake(0, 0, 320, 240) Images:set1 imageSize:CGSizeMake(120, 120) titles:nil];
    [ztsp setViewMargin:20];
    [ztsp setHeightOffset:20];
    [ztsp setPositionRatio:2];
    [ztsp setAlphaOfobjs:0.8];
    ztsp.clickblock = ^(NSInteger tag){
        NSLog(@"%ld",(long)tag);
    };
    
    ztsp.currentSelectBlock= ^(NSInteger tag){

    };

   
    [self.view addSubview:ztsp];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
