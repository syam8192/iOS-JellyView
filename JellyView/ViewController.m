//
//  ViewController.m
//  BowView
//
//  Created by syam8192 on 2015/04/08.
//  Copyright (c) 2015年 syam8192. All rights reserved.
//

#import "ViewController.h"
#import "JellyView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet JellyView *testView;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@end

@implementation ViewController {
    JellyViewPresetParams t;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //
    // パラメータを個別に設定する使い方.
    //
    _testView.jellyInsets = UIEdgeInsetsMake(30,30,30,30);
    _testView.inertia       = 0.5;
    _testView.attenuation   = 0.1;    // 剛性.
    _testView.fluctuation   = 0.8;    // 反発力.
    _testView.jellyColor    = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.6];
    
    t=-1;

}

/**
 * パラメータをプリセットから選ぶ使い方.
 */
- (IBAction)onClickedTypeButton:(id)sender {
    t++;
    if(t==eJellyViewPresetMax)t=0;
    [_testView setParamsWithPresetType:t];
    [_typeButton setTitle:[NSString stringWithFormat:@"やわらかLV %ld", (long)t]
                 forState:UIControlStateNormal];
}


- (IBAction)onClickedMoveButton:(id)sender {

    // UIViewのアニメーションでもちゃんとそれっぽくぽよぽよします.

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(){
                         self.testView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
                     }
                     completion:nil];
}


@end
