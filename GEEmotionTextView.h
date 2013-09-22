//
//  GEEmotionTextView.h
//  CBEmotionView
//
//  Created by sunyanliang on 13-9-21.
//  Copyright (c) 2013年. All rights reserved.
//
//ARC
//GEEmotionTextView 2.0版。1、支持文字和gif动画混排；2、精确计算视图高度。
/*
 -usage:(now just supports for chinese characters)
 
 //Example1-for common use:
 GEEmotionTextView* emotionView = [[GEEmotionTextView alloc] initWithFrame:CGRectMake(0, 0, 160, 0)];//no need to set height,sizeToFit can reset it.
 emotionView.emotionString = @"an emotion string...";
 emotionView.font = [UIFont systemFontOfSize:20];
 [self.view addSubview:emotionView];
 [emotionView sizeToFit];
 
 //Example2-for cell use:
 if (_emotionView == nil) {
 _emotionView = [[GEEmotionTextView alloc] initWithFrame:CGRectMake(10, 6, 300, 0)];//no need to set height, -sizeToFit will reset it.
 _emotionView.textColor = [UIColor colorWithRed:95.0/255.0 green:86.0/255.0 blue:70.0/255.0 alpha:1];
 [self.contentView addSubview:_emotionView];
 }
 _emotionView.emotionString =  @"an emotion string...";
 */
#import <UIKit/UIKit.h>

@interface GEEmotionTextView : UIView

@property (strong, nonatomic) UIFont* font;
@property (strong, nonatomic) UIColor* textColor;
@property (copy, nonatomic) NSString* emotionString;
@property (assign, nonatomic) BOOL heightAutosizing;
@property (assign, nonatomic) float rowInterval;
@property (assign, nonatomic) float characterInterval;

//exact.should be used after -addSubview:
-(void)sizeToFit;

@end
