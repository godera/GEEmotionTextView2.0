//
//  GEEmotionTextView.m
//  CBEmotionView
//
//  Created by sunyanliang on 13-9-21.
//  Copyright (c) 2013年. All rights reserved.
//

#import "GEEmotionTextView.h"
#import "GEGifView.h"
#import "GEEmotionCache.h"

@interface GEEmotionTextView ()
{
    CGFloat _rowHeight;
    CGPoint _point;// start-point for drawing
    NSMutableSet* _emotionViews;
}
@property (strong, nonatomic) NSDictionary* textAttributes;

@end


@implementation GEEmotionTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _rowInterval = 0.0f;
        _characterInterval = 2.0f;
        self.emotionString = @"";//default value
        self.font = [UIFont systemFontOfSize:15.0f];
        self.textColor = [UIColor blackColor];
        self.heightAutosizing = YES;
        _emotionViews = [NSMutableSet new];
    }
    return self;
}

-(void)setEmotionString:(NSString *)emotionString
{
    NSString* temp = [emotionString copy];
    _emotionString = temp;
    if (self.superview) {
        if (self.heightAutosizing == YES) {
            [self sizeToFit];
        }
        [self setNeedsDisplay];
    }
    
}

-(void)drawZiSimulation:(NSString*)currentZi
{
    // 1、判断画笔起始点
    CGFloat width = [currentZi sizeWithAttributes:_textAttributes].width;//widthForCurrentZi
    if (_point.x + width > CGRectGetWidth(self.bounds)) {//越界应该写在下一行
        _point.x = 0.0;
        _point.y += _rowHeight + _rowInterval;
    }
    // 2、移动画笔
    _point.x += width + _characterInterval;
}

// 表情的宽高都是单个文字的高（汉字的高比宽长）
-(void)addEmotionSimulation
{
    CGFloat emotionWidth = _rowHeight;
    // 1、判断画笔起始点
    if (_point.x + emotionWidth > CGRectGetWidth(self.bounds)) {//越界应该写在下一行
        _point.x = 0.0;
        _point.y += emotionWidth + _rowInterval;
    }
    // 2、移动画笔
    _point.x += emotionWidth + _characterInterval;
}

- (void)drawRectSimulation
{
    self.textAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor};
    NSString* zi = @"字";
    _rowHeight = [zi sizeWithAttributes:_textAttributes].height;
    
    _point = CGPointZero;
    NSInteger emotionStringLength = _emotionString.length;
    for (NSInteger i = 0; i < emotionStringLength; i++) {
        
        NSString* currentZi = [_emotionString substringWithRange:NSMakeRange(i, 1)];
        if ([currentZi isEqualToString:@"["]) {//有可能是表情
            
            NSInteger associatedIndex = i + 3;
            if (associatedIndex < emotionStringLength) {
                
                NSString* associatedZi = [_emotionString substringWithRange:NSMakeRange(associatedIndex, 1)];//表情格式是 "[表情]"，所以如果i+3是“]”，那么就代表是表情
                if ([associatedZi isEqualToString:@"]"]) {//是表情
                    
                    NSString* emotionZi = [_emotionString substringWithRange:NSMakeRange(i + 1, 2)];
                    
                    if ([GEEmotionCache objectForKey:emotionZi]) {//表情gif文件存在，表明有表情
                        [self addEmotionSimulation];
                    }else{//没有表情文件，直接显示文字啦~
                        [self drawZiSimulation:[_emotionString substringWithRange:NSMakeRange(i, 4)]];
                    }
                    
                    i += 3;
                    
                }else{//是文字
                    [self drawZiSimulation:currentZi];
                }
                
            }else{//只有左中括号，没有右中括号，认为是文字
                [self drawZiSimulation:currentZi];
            }
            
        }else{//是文字
            [self drawZiSimulation:currentZi];
        }
    }//endfor
}

-(void)sizeToFit
{
    [self drawRectSimulation];
    CGRect frame = self.frame;
    frame.size.height = _point.y + _rowHeight + _rowInterval;
    self.frame = frame;
}

-(void)drawZi:(NSString*)currentZi
{
    // 1、判断画笔起始点
    CGFloat width = [currentZi sizeWithAttributes:_textAttributes].width;//widthForCurrentZi
    if (_point.x + width > CGRectGetWidth(self.bounds)) {//越界应该写在下一行
        _point.x = 0.0;
        _point.y += _rowHeight + _rowInterval;
    }
    // 2、写文字
    [currentZi drawAtPoint:_point withAttributes:_textAttributes];
    // 3、移动画笔
    _point.x += width + _characterInterval;
}

// 表情的宽高都是单个文字的高（汉字的高比宽长）
-(void)addEmotion:(NSString*)emotionZi
{
    CGFloat emotionWidth = _rowHeight;
    // 1、判断画笔起始点
    if (_point.x + emotionWidth > CGRectGetWidth(self.bounds)) {//越界应该写在下一行
        _point.x = 0.0;
        _point.y += emotionWidth + _rowInterval;
    }
    // 2、增加表情视图
    GEGifView* emotionView = [GEGifView new];
    emotionView.frameItems = [GEEmotionCache objectForKey:emotionZi];
    emotionView.bounds = CGRectMake(0, 0, emotionWidth, emotionWidth);
    emotionView.center = CGPointMake(_point.x + emotionWidth / 2.0, _point.y + emotionWidth / 2.0);
    [self addSubview:emotionView];
    [_emotionViews addObject:emotionView];
    [emotionView start];
    
    /* for image,please use -imageNamed:
    [[UIImage imageWithContentsOfFile:gifPath] drawInRect:CGRectMake(_point.x, _point.y, _rowHeight, _rowHeight)];
     */
    // 3、移动画笔
    _point.x += emotionWidth + _characterInterval;
}

- (void)drawRect:(CGRect)rect
{
    // init
    self.textAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor};
    NSString* zi = @"字";
    _rowHeight = [zi sizeWithAttributes:_textAttributes].height;
    
    for (UIView* view in _emotionViews) {
        [view removeFromSuperview];
    }
    [_emotionViews removeAllObjects];
    
    _point = CGPointZero;
    
    NSInteger emotionStringLength = _emotionString.length;
    for (NSInteger i = 0; i < emotionStringLength; i++) {
        
        NSString* currentZi = [_emotionString substringWithRange:NSMakeRange(i, 1)];
        if ([currentZi isEqualToString:@"["]) {//有可能是表情
            
            NSInteger associatedIndex = i + 3;
            if (associatedIndex < emotionStringLength) {
                
                NSString* associatedZi = [_emotionString substringWithRange:NSMakeRange(associatedIndex, 1)];//表情格式是 "[表情]"，所以如果i+3是“]”，那么就代表是表情
                if ([associatedZi isEqualToString:@"]"]) {//是表情
                    
                    NSString* emotionZi = [_emotionString substringWithRange:NSMakeRange(i + 1, 2)];
                    
                    if ([GEEmotionCache objectForKey:emotionZi])//表情存在，添加表情
                    {
                        [self addEmotion:emotionZi];
//                        [self drawZi:[_emotionString substringWithRange:NSMakeRange(i, 4)]];
                    }
                    else//没有表情文件，直接显示文字啦~
                    {
                        [self drawZi:[_emotionString substringWithRange:NSMakeRange(i, 4)]];
                    }
                    
                    i += 3;
                    
                }else{//是文字
                    [self drawZi:currentZi];
                }
                
            }else{//只有左中括号，没有右中括号，认为是文字
                [self drawZi:currentZi];
            }
            
        }else{//是文字
            [self drawZi:currentZi];
        }
    }//endfor
}

@end
