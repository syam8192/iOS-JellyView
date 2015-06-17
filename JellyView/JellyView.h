//
//  JellyView.h
//  BowView
//
//  Created by syam8192 on 2015/04/08.
//  Copyright (c) 2015年 syam8192. All rights reserved.
//

#import <UIKit/UIKit.h>

// プリセットのパラメータ セット.
typedef enum : NSUInteger {
    eJellyViewPresetVeryHard,
    eJellyViewPresetHard,
    eJellyViewPresetMiddle,
    eJellyViewPresetSoft,
    eJellyViewPresetVerySoft,
    eJellyViewPresetMax
} JellyViewPresetParams;



/**
 *
 * View内に塗りつぶされた矩形を描画します。
 * 矩形の各辺は弓形に変形・振動します。
 * 変形・振動はAppのkeyWindow座標系でのViewの移動に応じて加速するので、
 * 基本的に置いて場所を動かすだけで勝手にぽよんぽよんします。
 * スライドして出現するUIの背景への利用などを想定してます。
 *
 * transformで拡大縮小回転したら何が起きるかは全然見てません. 回転とか多分ダメ.
 */


@interface JellyView : UIView

// 塗りつぶし色.
@property (nonatomic, retain) UIColor* jellyColor;

// ぷるぷるする用の余白。負は無視、０の辺はぷるぷるしない.
@property (nonatomic, assign) UIEdgeInsets jellyInsets;

// 移動による影響の大きさ（0-1）
@property (nonatomic, assign) CGFloat inertia;
// 剛性（振動の減衰の速さ）（0-1）
@property (nonatomic, assign) CGFloat attenuation;
// 反発力（振動の速さ）（0-1）
@property (nonatomic, assign) CGFloat fluctuation;
// 辺の歪みによる頂点の変形の度合い. 負数にすると歪み方が逆になる. 0にすると頂点が固定される.
@property (nonatomic, assign) CGFloat verticesAnimationRate;

/**
 * アニメーション開始.（Windowに追加された時点で自動的に呼ばれてる）
 */
- (void)startJellyAnimation;

/**
 * アニメーション停止.（removeFromSuperViewでも自動的に呼ばれる）
 */
- (void)stopJellyAnimation;

/**
 * 初期化（アニメーションの再生ON/OFFは変化しない）.
 */
- (void)resetJellyAnimation;

/**
 * プリセットから選んでパラメータを一括設定.
 */
- (void)setParamsWithPresetType:(JellyViewPresetParams)type;

@end
