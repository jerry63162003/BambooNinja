//
//  Defined.swift
//  BambooNiaja
//
//  Created by user04 on 2019/4/9.
//  Copyright © 2019年 jerryHU. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

let DefinedScreenLargeIphoneWidth:CGFloat = 1695
let DefinedScreenWidth:CGFloat = 1536
let DefinedScreenHeight:CGFloat = 2048
let screenWidth:CGFloat = UIScreen.main.bounds.width


var iPhoneNormalWidth:Bool {
    if screenWidth == CGFloat(375.0){
        return true
    } else {
        return false
    }
}
var iPhoneLargeWidth:Bool {
    if screenWidth == CGFloat(414.0){
        return true
    } else {
        return false
    }
}

enum StickHeroGameSceneChildName : String {
    case HeroName = "hero"
    case StickName = "stick"
    case StackName = "stack"
    case StackMidName = "stack_mid"
    case ScoreName = "score"
    case TipName = "tip"
    case PerfectName = "perfect"
    case GameOverLayerName = "over"
    case RetryButtonName = "retry"
    case GoToMainPage = "goToMainPage"
    case HighScoreName = "highscore"
}

enum StickHeroGameSceneActionKey: String {
    case WalkAction = "walk"
    case StickGrowAudioAction = "stick_grow_audio"
    case StickGrowAction = "stick_grow"
    case HeroScaleAction = "hero_scale"
}

enum StickHeroGameSceneEffectAudioName: String {
    case DeadAudioName = "dead.wav"
    case StickGrowAudioName = "stick_grow_loop.wav"
    case StickGrowOverAudioName = "kick.wav"
    case StickFallAudioName = "fall.wav"
    case StickTouchMidAudioName = "touch_mid.wav"
    case VictoryAudioName = "victory.wav"
    case HighScoreAudioName = "highScore.wav"
}

enum StickHeroGameSceneZposition: CGFloat {
    case backgroundZposition = 0
    case stackZposition = 30
    case stackMidZposition = 35
    case stickZposition = 40
    case scoreBackgroundZposition = 50
    case heroZposition, scoreZposition, tipZposition, perfectZposition = 100
    case emitterZposition
    case gameOverZposition
}
