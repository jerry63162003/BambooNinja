//
//  GameConfig.swift
//  BambooNiaja
//
//  Created by user04 on 2019/4/9.
//  Copyright © 2019年 jerryHU. All rights reserved.
//

import UIKit

let uGameMusic = "isGameMusic"
let uGameSound = "isGameSound"

class GameConfig: NSObject {
    
    var isGameMusic = UserDefaults.standard.object(forKey: uGameMusic) as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isGameMusic, forKey: uGameMusic)
            UserDefaults.standard.synchronize()
        }
    }
    var isGameSound = UserDefaults.standard.object(forKey: uGameSound) as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isGameSound, forKey: uGameSound)
            UserDefaults.standard.synchronize()
        }
    }
    
}
