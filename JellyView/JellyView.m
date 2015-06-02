//
//  JellyView.m
//  BowView
//
//  Created by syam8192 on 2015/04/08.
//  Copyright (c) 2015年 syam8192. All rights reserved.
//

#import "JellyView.h"

#define TEST_TOUCH_ENABLED

@interface JellyView ()
@property (nonatomic, retain) CADisplayLink* displayLink;
@property (nonatomic, readonly) CGPoint currentCenterOnKeyWindow;
@end


/**
 *
 * ジェリー状にぷるぷるする領域を描画するView.
 *
 * TODO: アニメーション時間がフレームレートに依存するので、フレームスキップも実装しときたい.
 */
@implementation JellyView {

    float p[4]; // コントロールポイントの位置.（後述）
    float v[4]; // コントロールポイントの速度.

    CGPoint prevCenter; // 前フレームの center
    BOOL jellyAnimating; // アニメーション中フラグ.

#ifdef TEST_TOUCH_ENABLED
    // テスト用. タッチ＆スライドで移動可能に.
    CGPoint touchedPos;
    CGPoint touchedOrg;
#endif

}

/**
 * アニメーション開始（runLoopへの登録）.
 */
- (void)startJellyAnimation {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateJelly)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self resetJellyAnimation];
}
/**
 * アニメーション停止（runLoopから除去）.
 */
- (void)stopJellyAnimation {
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = nil;
}
/**
 * アニメーション初期化.
 */
- (void)resetJellyAnimation {
    prevCenter = self.currentCenterOnKeyWindow;
    for (int i=0; i<4; i++) {
        p[i] = 0;
        v[i] = 0;
    }
    jellyAnimating = NO;
}


/**
 * プリセットのパラメータ設定.
 */
- (void)setParamsWithPresetType:(JellyViewPresetParams)type {
    switch (type) {
        case eJellyViewPresetVeryHard:
            self.inertia       = 0.2;    // 慣性.
            self.attenuation   = 0.6;    // 剛性.
            self.fluctuation   = 0.3;    // 反発力.
            break;
        case eJellyViewPresetHard:
            self.inertia       = 0.3;    // 慣性.
            self.attenuation   = 0.3;    // 剛性.
            self.fluctuation   = 0.6;    // 反発力.
            break;
        case eJellyViewPresetMiddle:
            self.inertia       = 0.5;    // 慣性.
            self.attenuation   = 0.2;    // 剛性.
            self.fluctuation   = 0.7;    // 反発力.
            break;
        case eJellyViewPresetSoft:
            self.inertia       = 0.7;    // 慣性.
            self.attenuation   = 0.15;    // 剛性.
            self.fluctuation   = 0.8;    // 反発力.
            break;
        case eJellyViewPresetVerySoft:
            self.inertia       = 0.8;    // 慣性.
            self.attenuation   = 0.05;    // 剛性.
            self.fluctuation   = 0.9;    // 反発力.
            break;
        default:
            break;
    }
}

/**
 * プロパティのリミッター.
 */
- (void)setInertia:(CGFloat)inertia {
    _inertia = MAX(MIN(inertia,1),0);
}
- (void)setAattenuation:(CGFloat)attenuation {
    _attenuation = MAX(MIN(attenuation,1),0);
    _attenuation = _attenuation*_attenuation;
}
- (void)setFluctuation:(CGFloat)fluctuation {
    _fluctuation = MAX(MIN(fluctuation,1),0);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self startJellyAnimation];
}

- (void)removeFromSuperview {
    [self stopJellyAnimation];
    [super removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    //
    // ベジエ曲線または直線を４本組み合わせた範囲を塗りつぶす.
    //
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_jellyInsets.left, _jellyInsets.top)];

    // コントロールポイントを 辺を３等分したあたりに置いて 垂直方向に移動させる.
    // 位置 p[] は、辺を３等分する点からコントロールポイントまでの距離.
    CGSize ctrl = CGSizeMake((self.bounds.size.width-_jellyInsets.left-_jellyInsets.right) / 3,
                             (self.bounds.size.height-_jellyInsets.top-_jellyInsets.bottom) / 3);

    // 上辺.
    if ( _jellyInsets.top>0 && ABS(p[0])>0.01 ) {
        [path addCurveToPoint:CGPointMake( self.bounds.size.width-_jellyInsets.right, _jellyInsets.top)
                controlPoint1:CGPointMake( _jellyInsets.left + ctrl.width, _jellyInsets.top + p[0])
                controlPoint2:CGPointMake( self.bounds.size.width-_jellyInsets.right - ctrl.width, _jellyInsets.top + p[0])];
    }
    else {
        [path addLineToPoint:CGPointMake( self.bounds.size.width-_jellyInsets.right, _jellyInsets.top)];
    }
    // 右辺.
    if ( _jellyInsets.right>0 && ABS(p[1])>0.01) {
        [path addCurveToPoint:CGPointMake( self.bounds.size.width-_jellyInsets.right, self.bounds.size.height - _jellyInsets.bottom)
                controlPoint1:CGPointMake( self.bounds.size.width-_jellyInsets.right+p[1], _jellyInsets.top+ctrl.height)
                controlPoint2:CGPointMake( self.bounds.size.width-_jellyInsets.right+p[1], self.bounds.size.height - _jellyInsets.bottom-+ctrl.height)];
    }
    else {
        [path addLineToPoint:CGPointMake( self.bounds.size.width-_jellyInsets.right, self.bounds.size.height- _jellyInsets.bottom)];
    }
    // 下辺.
    if ( _jellyInsets.bottom>0 && ABS(p[2])>0.01) {
        [path addCurveToPoint:CGPointMake( _jellyInsets.left, self.bounds.size.height- _jellyInsets.bottom)
                controlPoint1:CGPointMake( self.bounds.size.width-_jellyInsets.right - ctrl.width, self.bounds.size.height- _jellyInsets.bottom + p[2] )
                controlPoint2:CGPointMake(_jellyInsets.left + ctrl.width, self.bounds.size.height - _jellyInsets.bottom + p[2] )];
    }
    else {
        [path addLineToPoint:CGPointMake(_jellyInsets.left, self.bounds.size.height- _jellyInsets.bottom)];
    }
    // 左辺.
    if ( _jellyInsets.right>0 && ABS(p[3])>0.01) {
        [path addCurveToPoint:CGPointMake( _jellyInsets.left, _jellyInsets.top )
                controlPoint1:CGPointMake( _jellyInsets.left+p[3], self.bounds.size.height - _jellyInsets.bottom-ctrl.height)
                controlPoint2:CGPointMake( _jellyInsets.left+p[3], _jellyInsets.top+ctrl.height )];
    }
    else {
        [path addLineToPoint:CGPointMake( _jellyInsets.left, _jellyInsets.top)];
    }

    // 塗る.
    [_jellyColor setFill];
    [path fill];
}


/**
 * コントロールポイントの位置を再計算.
 */
- (void)updateJelly {

    CGPoint cp = self.currentCenterOnKeyWindow;
    CGSize d = CGSizeMake(cp.x-prevCenter.x, cp.y-prevCenter.y);
    prevCenter = cp;

    BOOL needsDisplay = NO;
    for (int i=0; i<4; i++) {
        v[i] -= ((i%2) ?d.width:d.height) * _inertia;   // 速度 -= 自Viewの移動量 * 係数.
        v[i] += -p[i] * (1-_fluctuation);               // 速度 += ( 初期位置(0)-現在位置 ) * 剛性係数.
        p[i] += v[i];                                   // 位置 += 速度.
        v[i] *= (1.0-_attenuation);                     // 速度 *= 減衰係数.
        needsDisplay |= (p[i]>0.01) || (p[i]<-0.01);
        needsDisplay |= (v[i]>0.01) || (v[i]<-0.01);    // 位置,速度 がすべてしきい値を下回ったらアニメーションを止める.
    }

    if ( needsDisplay ) {
        // 再描画が必要.
        jellyAnimating = YES;
        [self setNeedsDisplay];
    }
    else {
        // 再描画不要.
        if ( jellyAnimating ) {
            // ただしアニメーションが終わったばかりのときは初期状態を１回だけ再描画.
            [self resetJellyAnimation];
            [self setNeedsDisplay];
        }
    }
}

/**
 * キーウインドウ座標系での現在の自分のcenter.
 * アニメーション中はアニメーション途中の値を返す.
 */
- (CGPoint)currentCenterOnKeyWindow {
    CALayer* animLayer = self.layer.presentationLayer;
    CGPoint c;
    if ( animLayer ) {
        // アニメーション中の見た目の位置は frame では取れない. presentationLayerを使う.
        CGRect r = animLayer.frame;
        c = CGPointMake(r.origin.x+r.size.width/2, r.origin.y+r.size.height/2);
    }
    else {
        // アニメーションしてないなど presentationLayerがない場合は素直に center を使う.
        c = self.center;
    }
    return [self.superview convertPoint:c toView:[UIApplication sharedApplication].keyWindow];
}


//
// テスト用. タッチでスライドする機能を付加.
//
#ifdef TEST_TOUCH_ENABLED
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    touchedPos = [touch locationInView:self.superview];
    touchedOrg = self.frame.origin;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint newPos = [touch locationInView:self.superview];
    CGRect rect = self.frame;
    rect.origin.x = touchedOrg.x + newPos.x - touchedPos.x;
    rect.origin.y = touchedOrg.y + newPos.y - touchedPos.y;
    self.frame = rect;
}
#endif

@end
