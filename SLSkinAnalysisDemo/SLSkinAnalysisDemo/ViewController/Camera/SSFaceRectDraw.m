//
//  SSFaceRectDraw.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/27.
//

#import "SSFaceRectDraw.h"

@interface SSFaceRectDraw ()
@property (nonatomic, strong) NSLock *drawLock;
@property (nonatomic, assign) CGRect faceRect;
@property (nonatomic, strong) UIBezierPath *drawPath;
@end

@implementation SSFaceRectDraw

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _drawLock = [[NSLock alloc]init];
    }
    return self;
}

- (void)drawFaceRect:(CGRect)faceRect {
    [_drawLock lock];
    _faceRect = faceRect;
    [_drawLock unlock];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [_drawLock lock];
    [[UIColor redColor]setStroke];
    if (CGRectEqualToRect(_faceRect, CGRectZero)) {
        _drawPath = nil;
        [_drawLock unlock];
        return;
    }
    _drawPath = nil;
    _drawPath = [UIBezierPath bezierPathWithRect:self.faceRect];
    _drawPath.lineWidth = 2.0;
    [_drawPath stroke];
    [_drawLock unlock];
}
@end
