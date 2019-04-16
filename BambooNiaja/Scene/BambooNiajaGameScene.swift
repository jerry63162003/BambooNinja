//
//  BambooNiajaGameScene.swift
//  BambooNiaja
//
//  Created by user04 on 2019/4/9.
//  Copyright © 2019年 jerryHU. All rights reserved.
//

import SpriteKit
import AVFoundation

class BambooNiajaGameScene: SKScene, SKPhysicsContactDelegate {
    struct GAP {
        static let XGAP:CGFloat = 20
        static let YGAP:CGFloat = 4
    }

    var gameOver = false {
        willSet {
            if (newValue) {
                checkHighScoreAndStore()
                let gameOverLayer = childNode(withName: BambooNiajaGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
                gameOverLayer?.run(SKAction.moveDistance(CGVector(dx: 0, dy: 100), fadeInWithDuration: 0.2))
                
            }
        }
    }
    
    let StackHeight:CGFloat = 400.0
    let StackMaxWidth:CGFloat = 300.0
    let StackMinWidth:CGFloat = 100.0
    let gravity:CGFloat = -100.0
    let StackGapMinWidth:Int = 80
    let HeroSpeed:CGFloat = 760
    let StoreScoreName = "com.BambooNiaja.score"
    let isGameMusic = GameConfig().isGameMusic
    let isGameSound = GameConfig().isGameSound
    
    var isBegin = false
    var isEnd = false
    var leftStack:SKShapeNode?
    var rightStack:SKShapeNode?
    var hero: SKSpriteNode!
    var stick: SKSpriteNode!
    var musicPlayer:AVAudioPlayer!
    
    var nextLeftStartX:CGFloat = 0
    var stickHeight:CGFloat = 0
    
    var score:Int = 0 {
        willSet {
            let scoreBand = childNode(withName: BambooNiajaGameSceneChildName.ScoreName.rawValue) as? SKLabelNode
            scoreBand?.text = "\(newValue)"
            scoreBand?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.1), SKAction.scale(to: 1, duration: 0.1)]))
            
            if (newValue == 1) {
                let tip = childNode(withName: BambooNiajaGameSceneChildName.TipName.rawValue) as? SKLabelNode
                tip?.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
            }
        }
    }
    
    lazy var playAbleRect:CGRect = {
        let maxAspectRatio:CGFloat = 16.0/9.0 // iPhone 5"
        let maxAspectRatioWidth = self.size.height / maxAspectRatio
        let playableMargin = (self.size.width - maxAspectRatioWidth) / 2.0
        return CGRect(x: playableMargin, y: 0, width: maxAspectRatioWidth, height: self.size.height)
        }()
    
    lazy var walkAction:SKAction = {
        var textures:[SKTexture] = []
        for i in 0...1 {
            let texture = SKTexture(imageNamed: "human\(i + 1).png")
            textures.append(texture)
        }
        
        let action = SKAction.animate(with: textures, timePerFrame: 0.15, resize: true, restore: true)
        
        return SKAction.repeatForever(action)
        }()
    
    //MARK: - override
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
        if isGameMusic == true {
            musicPlayer = setupAudioPlayerWithFile("bg_country", type: "mp3")
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        }
    }

    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        let url = Bundle.main.url(forResource: file as String, withExtension: type as String)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url!)
        } catch {
            print("NO AUDIO PLAYER")
        }
        
        return audioPlayer!
    }
    
    override func didMove(to view: SKView) {
        start()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameOver else {
            let gameOverLayer = childNode(withName: BambooNiajaGameSceneChildName.GameOverLayerName.rawValue) as SKNode?

            let location = touches.first?.location(in: gameOverLayer!)
            let retry = gameOverLayer!.atPoint(location!)
            let goToMainPage = gameOverLayer!.atPoint(location!)
            
            if (retry.name == BambooNiajaGameSceneChildName.RetryButtonName.rawValue) {
                retry.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "button_retry_up"), resize: false), SKAction.wait(forDuration: 0.3)]), completion: {[unowned self] () -> Void in
                    self.restart()
                })
            }
            
            if (goToMainPage.name == BambooNiajaGameSceneChildName.GoToMainPage.rawValue) {
                leftStack?.removeFromParent()
                rightStack?.removeFromParent()
                hero.removeFromParent()
                stick.removeFromParent()
                self.removeAllActions()
                self.removeAllChildren()
                if isGameMusic == true {
                    musicPlayer.stop()
                }
                var topController:UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!
                let vc = ViewController()
                
                while ((topController.presentedViewController) != nil) {
                    topController = topController.presentedViewController!
                }
                
                topController.present(vc, animated: true, completion: nil)
            }
            
            return
        }
        
        if !isBegin && !isEnd {
            isBegin = true
            
            let stick = loadStick()
            hero = childNode(withName: BambooNiajaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
     
            let action = SKAction.resize(toHeight: CGFloat(DefinedScreenHeight - StackHeight), duration: 1.5)
            stick.run(action, withKey:BambooNiajaGameSceneActionKey.BambooGrowAction.rawValue)
            
            let scaleAction = SKAction.sequence([SKAction.scaleY(to: 0.9, duration: 0.05), SKAction.scaleY(to: 1, duration: 0.05)])
            if isGameMusic == true {
                let loopAction = SKAction.group([SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.BambooGrowAudioName.rawValue, waitForCompletion: true)])
                stick.run(SKAction.repeatForever(loopAction), withKey: BambooNiajaGameSceneActionKey.BambooGrowAudioAction.rawValue)
                hero.run(SKAction.repeatForever(scaleAction), withKey: BambooNiajaGameSceneActionKey.HeroScaleAction.rawValue)
            }
            return
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isBegin && !isEnd {
            isEnd  = true
            
            hero = childNode(withName: BambooNiajaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
            hero.removeAction(forKey: BambooNiajaGameSceneActionKey.HeroScaleAction.rawValue)
            hero.run(SKAction.scaleY(to: 1, duration: 0.04))
            
            stick = childNode(withName: BambooNiajaGameSceneChildName.BambooName.rawValue) as? SKSpriteNode
            stick.removeAction(forKey: BambooNiajaGameSceneActionKey.BambooGrowAction.rawValue)
            stick.removeAction(forKey: BambooNiajaGameSceneActionKey.BambooGrowAudioAction.rawValue)
            
            if isGameSound == true {
                stick.run(SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.BambooGrowOverAudioName.rawValue, waitForCompletion: false))
            }
            
            stickHeight = stick.size.height;
            
            let action = SKAction.rotate(toAngle: CGFloat(-Double.pi / 2), duration: 0.4, shortestUnitArc: true)
            var playFall = SKAction()
            if isGameSound == true {
                playFall = SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.BambooFallAudioName.rawValue, waitForCompletion: false)
            }
            
            stick.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), action, playFall]), completion: {[unowned self] () -> Void in
                self.heroGo(self.checkPass())
            })
        }
    }
    
    func start() {
        loadBackground()
        loadScoreBackground()
        loadScore()
        loadTip()
        loadGameOverLayer()
 
        leftStack = loadStacks(false, startLeftPoint: playAbleRect.origin.x)
        self.removeMidTouch(false, left:true)
        loadHero()
 
        let maxGap = Int(playAbleRect.width - StackMaxWidth - (leftStack?.frame.size.width)!)
        
        let gap = CGFloat(randomInRange(StackGapMinWidth...maxGap))
        rightStack = loadStacks(false, startLeftPoint: nextLeftStartX + gap)
        
        gameOver = false
    }
    
    func restart() {
        //记录分数
        isBegin = false
        isEnd = false
        score = 0
        nextLeftStartX = 0
        removeAllChildren()
        start()
    }
    
    fileprivate func checkPass() -> Bool {
        stick = childNode(withName: BambooNiajaGameSceneChildName.BambooName.rawValue) as? SKSpriteNode

        let rightPoint = DefinedScreenWidth / 2 + stick.position.x + self.stickHeight
        
        guard rightPoint < self.nextLeftStartX else {
            return false
        }
        
        guard ((leftStack?.frame)!.intersects(stick.frame) && (rightStack?.frame)!.intersects(stick.frame)) else {
            return false
        }
        
        self.checkTouchMidStack()
        
        return true
    }
    
    fileprivate func checkTouchMidStack() {
        stick = childNode(withName: BambooNiajaGameSceneChildName.BambooName.rawValue) as? SKSpriteNode
        let stackMid = rightStack!.childNode(withName: BambooNiajaGameSceneChildName.StackMidName.rawValue) as! SKShapeNode
        
        let newPoint = stackMid.convert(CGPoint(x: -10, y: 10), to: self)
        
        if ((stick.position.x + self.stickHeight) >= newPoint.x  && (stick.position.x + self.stickHeight) <= newPoint.x + 20) {
            loadPerfect()
            if isGameSound == true {
                self.run(SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.BambooTouchMidAudioName.rawValue, waitForCompletion: false))
            }
            score += 1
        }
 
    }
    
    fileprivate func removeMidTouch(_ animate:Bool, left:Bool) {
        let stack = left ? leftStack : rightStack
        let mid = stack!.childNode(withName: BambooNiajaGameSceneChildName.StackMidName.rawValue) as! SKShapeNode
        if (animate) {
            mid.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        }
        else {
            mid.removeFromParent()
        }
    }
    
    fileprivate func heroGo(_ pass:Bool) {
        hero = childNode(withName: BambooNiajaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
        
        guard pass else {
            stick = childNode(withName: BambooNiajaGameSceneChildName.BambooName.rawValue) as? SKSpriteNode
            
            let dis:CGFloat = stick.position.x + self.stickHeight
            
            let overGap = DefinedScreenWidth / 2 - abs(hero.position.x)
            let disGap = nextLeftStartX - overGap - (rightStack?.frame.size.width)! / 2

            let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / HeroSpeed)))

            hero.run(walkAction, withKey: BambooNiajaGameSceneActionKey.WalkAction.rawValue)
            hero.run(move, completion: {[unowned self] () -> Void in
                self.stick.run(SKAction.rotate(toAngle: CGFloat(-Double.pi), duration: 0.4))
                
                self.hero.physicsBody!.affectedByGravity = true
                if self.isGameSound == true {
                    self.hero.run(SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.DeadAudioName.rawValue, waitForCompletion: false))
                }
                self.hero.removeAction(forKey: BambooNiajaGameSceneActionKey.WalkAction.rawValue)
                self.run(SKAction.wait(forDuration: 0.5), completion: {[unowned self] () -> Void in
                    self.gameOver = true
                })
            })

            return
        }
        
        let dis:CGFloat = nextLeftStartX - DefinedScreenWidth / 2 - hero.size.width / 2 - GAP.XGAP
        
        let overGap = DefinedScreenWidth / 2 - abs(hero.position.x)
        let disGap = nextLeftStartX - overGap - (rightStack?.frame.size.width)! / 2
        
        let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / HeroSpeed)))
 
        hero.run(walkAction, withKey: BambooNiajaGameSceneActionKey.WalkAction.rawValue)
        hero.run(move, completion: { [unowned self]() -> Void in
            self.score += 1
            if self.isGameSound == true {
                self.hero.run(SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.VictoryAudioName.rawValue, waitForCompletion: false))
            }
            self.hero.removeAction(forKey: BambooNiajaGameSceneActionKey.WalkAction.rawValue)
            self.moveStackAndCreateNew()
        }) 
    }
    
    fileprivate func checkHighScoreAndStore() {
        let highScore = UserDefaults.standard.integer(forKey: StoreScoreName)
        if (score > Int(highScore)) {
            showHighScore()
            
            UserDefaults.standard.set(score, forKey: StoreScoreName)
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate func showHighScore() {
        if isGameSound == true {
            self.run(SKAction.playSoundFileNamed(BambooNiajaGameSceneEffectAudioName.HighScoreAudioName.rawValue, waitForCompletion: false))
        }
        
        let wait = SKAction.wait(forDuration: 0.4)
        let grow = SKAction.scale(to: 1.5, duration: 0.4)
        grow.timingMode = .easeInEaseOut
        let explosion = starEmitterActionAtPosition(CGPoint(x: 0, y: 300))
        let shrink = SKAction.scale(to: 1, duration: 0.2)
       
        let idleGrow = SKAction.scale(to: 1.2, duration: 0.4)
        idleGrow.timingMode = .easeInEaseOut
        let idleShrink = SKAction.scale(to: 1, duration: 0.4)
        let pulsate = SKAction.repeatForever(SKAction.sequence([idleGrow, idleShrink]))
        
        let gameOverLayer = childNode(withName: BambooNiajaGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
        let highScoreLabel = gameOverLayer?.childNode(withName: BambooNiajaGameSceneChildName.HighScoreName.rawValue) as SKNode?
        highScoreLabel?.run(SKAction.sequence([wait, explosion, grow, shrink]), completion: { () -> Void in
            highScoreLabel?.run(pulsate)
        })
    }
    
    fileprivate func moveStackAndCreateNew() {
        let action = SKAction.move(by: CGVector(dx: -nextLeftStartX + (rightStack?.frame.size.width)! + playAbleRect.origin.x - 2, dy: 0), duration: 0.3)
        rightStack?.run(action)
        self.removeMidTouch(true, left:false)

        hero = childNode(withName: BambooNiajaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
        stick = childNode(withName: BambooNiajaGameSceneChildName.BambooName.rawValue) as? SKSpriteNode
        
        hero.run(action)
        stick.run(SKAction.group([SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), SKAction.fadeAlpha(to: 0, duration: 0.3)]), completion: { () -> Void in
            self.stick.removeFromParent()
        }) 
        
        leftStack?.run(SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), completion: {[unowned self] () -> Void in
            self.leftStack?.removeFromParent()
            
            let maxGap = Int(self.playAbleRect.width - (self.rightStack?.frame.size.width)! - self.StackMaxWidth)
            let gap = CGFloat(randomInRange(self.StackGapMinWidth...maxGap))
            
            self.leftStack = self.rightStack
            self.rightStack = self.loadStacks(true, startLeftPoint:self.playAbleRect.origin.x + (self.rightStack?.frame.size.width)! + gap)
        })
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - load node
private extension BambooNiajaGameScene {
    func loadBackground() {
        guard let _ = childNode(withName: "background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "stick_background.png")!)
            let node = SKSpriteNode(texture: texture)
            node.size = texture.size()
            node.zPosition = BambooNiajaGameSceneZposition.backgroundZposition.rawValue
            self.physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
            
            addChild(node)
            return
        }
    }
    
    func loadScore() {
        let scoreBand = SKLabelNode(fontNamed: "Arial")
        scoreBand.name = BambooNiajaGameSceneChildName.ScoreName.rawValue
        scoreBand.text = "0"
        scoreBand.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 200)
        scoreBand.fontColor = SKColor.white
        scoreBand.fontSize = 100
        scoreBand.zPosition = BambooNiajaGameSceneZposition.scoreZposition.rawValue
        scoreBand.horizontalAlignmentMode = .center
        
        addChild(scoreBand)
    }
    
    func loadScoreBackground() {
        let back = SKShapeNode(rect: CGRect(x: 0-120, y: 1024-200-30, width: 240, height: 140), cornerRadius: 20)
        back.zPosition = BambooNiajaGameSceneZposition.scoreBackgroundZposition.rawValue
        back.fillColor = SKColor.black.withAlphaComponent(0.3)
        back.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(back)
    }
    
    func loadHero() {
        hero = SKSpriteNode(imageNamed: "human1")
        hero.name = BambooNiajaGameSceneChildName.HeroName.rawValue
        let x:CGFloat = nextLeftStartX - DefinedScreenWidth / 2 - hero.size.width / 2 - GAP.XGAP
        let y:CGFloat = StackHeight + hero.size.height / 2 - DefinedScreenHeight / 2 - GAP.YGAP
        hero.position = CGPoint(x: x, y: y)
        hero.zPosition = BambooNiajaGameSceneZposition.heroZposition.rawValue
        hero.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 18))
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.allowsRotation = false
        
        addChild(hero)
    }
    
    func loadTip() {
        let tip = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        tip.name = BambooNiajaGameSceneChildName.TipName.rawValue
        tip.text = "将手放在屏幕使竿变长"
        tip.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 350)
        tip.fontColor = SKColor.black
        tip.fontSize = 52
        tip.zPosition = BambooNiajaGameSceneZposition.tipZposition.rawValue
        tip.horizontalAlignmentMode = .center
    
        addChild(tip)
    }
    
    func loadPerfect() {
        defer {
            let perfect = childNode(withName: BambooNiajaGameSceneChildName.PerfectName.rawValue) as! SKLabelNode?
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.3), SKAction.fadeAlpha(to: 0, duration: 0.3)])
            let scale = SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            perfect!.run(SKAction.group([sequence, scale]))
        }

        guard let _ = childNode(withName: BambooNiajaGameSceneChildName.PerfectName.rawValue) as! SKLabelNode? else {
            let perfect = SKLabelNode(fontNamed: "Arial")
            perfect.text = "Perfect +1"
            perfect.name = BambooNiajaGameSceneChildName.PerfectName.rawValue
            perfect.position = CGPoint(x: 0, y: -100)
            perfect.fontColor = SKColor.black
            perfect.fontSize = 50
            perfect.zPosition = BambooNiajaGameSceneZposition.perfectZposition.rawValue
            perfect.horizontalAlignmentMode = .center
            perfect.alpha = 0
            
            addChild(perfect)
            
            return
        }
       
    }
    
    func loadStick() -> SKSpriteNode {
        hero = childNode(withName: BambooNiajaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode

        stick = SKSpriteNode(color: SKColor.black, size: CGSize(width: 12, height: 1))
        stick.zPosition = BambooNiajaGameSceneZposition.bambooZposition.rawValue
        stick.name = BambooNiajaGameSceneChildName.BambooName.rawValue
        stick.anchorPoint = CGPoint(x: 0.5, y: 0);
        stick.position = CGPoint(x: hero.position.x + hero.size.width / 2 + 18, y: hero.position.y - hero.size.height / 2)
        addChild(stick)
        
        return stick
    }
    
    func loadStacks(_ animate: Bool, startLeftPoint: CGFloat) -> SKShapeNode {
        let max:Int = Int(StackMaxWidth / 10)
        let min:Int = Int(StackMinWidth / 10)
        let width:CGFloat = CGFloat(randomInRange(min...max) * 10)
        let height:CGFloat = StackHeight
        let stack = SKShapeNode(rectOf: CGSize(width: width, height: height))
        stack.fillColor = SKColor.black
        stack.strokeColor = SKColor.black
        stack.zPosition = BambooNiajaGameSceneZposition.stackZposition.rawValue
        stack.name = BambooNiajaGameSceneChildName.StackName.rawValue
 
        if (animate) {
            stack.position = CGPoint(x: DefinedScreenWidth / 2, y: -DefinedScreenHeight / 2 + height / 2)
            
            stack.run(SKAction.moveTo(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3), completion: {[unowned self] () -> Void in
                self.isBegin = false
                self.isEnd = false
            })
            
        }
        else {
            stack.position = CGPoint(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, y: -DefinedScreenHeight / 2 + height / 2)
        }
        addChild(stack)
        
        let mid = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        mid.fillColor = SKColor.red
        mid.strokeColor = SKColor.red
        mid.zPosition = BambooNiajaGameSceneZposition.stackMidZposition.rawValue
        mid.name = BambooNiajaGameSceneChildName.StackMidName.rawValue
        mid.position = CGPoint(x: 0, y: height / 2 - 20 / 2)
        stack.addChild(mid)
        
        nextLeftStartX = width + startLeftPoint
        
        return stack
    }

    func loadGameOverLayer() {
        let node = SKNode()
        node.alpha = 0
        node.name = BambooNiajaGameSceneChildName.GameOverLayerName.rawValue
        node.zPosition = BambooNiajaGameSceneZposition.gameOverZposition.rawValue
        addChild(node)
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "Game Over"
        label.fontColor = SKColor.red
        label.fontSize = 150
        label.position = CGPoint(x: 0, y: 100)
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        
        let retry = SKSpriteNode(imageNamed: "button_retry_up")
        retry.name = BambooNiajaGameSceneChildName.RetryButtonName.rawValue
        retry.position = CGPoint(x: 0, y: -200)
        node.addChild(retry)
        
        let goToMainPage = SKSpriteNode(imageNamed: "again")
        goToMainPage.name = BambooNiajaGameSceneChildName.GoToMainPage.rawValue
        goToMainPage.position = CGPoint(x: 0, y: 0)
        node.addChild(goToMainPage)
        
        let highScore = SKLabelNode(fontNamed: "AmericanTypewriter")
        highScore.text = "Highscore!"
        highScore.fontColor = UIColor.white
        highScore.fontSize = 50
        highScore.name = BambooNiajaGameSceneChildName.HighScoreName.rawValue
        highScore.position = CGPoint(x: 0, y: 300)
        highScore.horizontalAlignmentMode = .center
        highScore.setScale(0)
        node.addChild(highScore)
    }
    
    //MARK: - Action
    func starEmitterActionAtPosition(_ position: CGPoint) -> SKAction {
        let emitter = SKEmitterNode(fileNamed: "StarExplosion")
        emitter?.position = position
        emitter?.zPosition = BambooNiajaGameSceneZposition.emitterZposition.rawValue
        emitter?.alpha = 0.6
        addChild((emitter)!)
        
        let wait = SKAction.wait(forDuration: 0.15)

        return SKAction.run({ () -> Void in
           emitter?.run(wait)
        })
    }

}
