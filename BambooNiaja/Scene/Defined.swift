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

enum BambooNiajaGameSceneChildName : String {
    case HeroName = "Niaja"
    case BambooName = "Bamboo"
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

enum BambooNiajaGameSceneActionKey: String {
    case WalkAction = "walk"
    case BambooGrowAudioAction = "bamboo_grow_audio"
    case BambooGrowAction = "bamboo_grow"
    case HeroScaleAction = "hero_scale"
}

enum BambooNiajaGameSceneEffectAudioName: String {
    case DeadAudioName = "dead.wav"
    case BambooGrowAudioName = "bamboo_grow_loop.wav"
    case BambooGrowOverAudioName = "kick.wav"
    case BambooFallAudioName = "fall.wav"
    case BambooTouchMidAudioName = "touch_mid.wav"
    case VictoryAudioName = "victory.wav"
    case HighScoreAudioName = "highScore.wav"
}

enum BambooNiajaGameSceneZposition: CGFloat {
    case backgroundZposition = 0
    case stackZposition = 30
    case stackMidZposition = 35
    case bambooZposition = 40
    case scoreBackgroundZposition = 50
    case heroZposition, scoreZposition, tipZposition, perfectZposition = 100
    case emitterZposition
    case gameOverZposition
}
