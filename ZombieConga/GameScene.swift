//
//  GameScene.swift
//  ZombieConga
//
//  Created by Charles Hsu on 12/2/14.
//  Copyright (c) 2014 Loxoll. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // property section
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieMovePointsPerSec: CGFloat = 480.0
    let playableRect: CGRect
    let zombieRotateRadiansPerSec:CGFloat = 3.0 * π
    let enemySpawnDuration = 3.0
    let zombieAnimation: SKAction
    let zombieAnimationKey = "animation"
    let catMovePointsPerSec: CGFloat = 480.0
    let backgroundMovePointPerSec: CGFloat = 200.0
    
    let backgroundLayer = SKNode()
    
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav",
                                      waitForCompletion: false)
    // http://www.flashkit.com/soundfx/Cartoon/wheeee-Public_D-399/index.php
    //let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("wheeee-Public_D-399_hifi.mp3",
    //                                    waitForCompletion: false)
    
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav",
                                        waitForCompletion: false)

    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocityVector = CGPointZero
    var isFrozen: Bool = false
    var lastTouchLocation: CGPoint?
    var isInvicible = false
    
    var lives = 5
    var gameOver = false
    
    //var testUpdateCount:Int32 = 0
    //var testDidEvaluateActionsCount:Int32 = 0

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        
        
        zombieAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startZombieAnimation() {
         if zombie.actionForKey(zombieAnimationKey) == nil {
            zombie.runAction(
                SKAction.repeatActionForever(zombieAnimation),
                withKey: zombieAnimationKey)
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey(zombieAnimationKey)
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 0.4
        addChild(shape)
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPointZero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPointZero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        
        return backgroundNode
    }
    
    func moveBackground() {
        
        let backgroundVelocity = CGPoint(x: -backgroundMovePointPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundLayer.position += amountToMove
        
        
        enumerateChildNodesWithName("background") { node, _ in
            
            let background = node as SKSpriteNode
            
            let backgroundScreenPos = self.backgroundLayer.convertPoint(
                background.position, toNode: self)
            
            //let backgroundVelocity = CGPoint(x: -self.backgroundMovePointPerSec, y: 0)
            //let amountToMove = backgroundVelocity * CGFloat(self.dt)
            //background.position += amountToMove
            
            //println("background.position.x = \(background.position.x) ||| -background.size.width = \(-background.size.width)")
            
            //if background.position.x <= -background.size.width {
            if backgroundScreenPos.x <= -background.size.width {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }

    override func didMoveToView(view: SKView) {
        
        backgroundLayer.zPosition = -1
        addChild(backgroundLayer)
        
        backgroundColor = SKColor.whiteColor()
        
        //let background = SKSpriteNode(imageNamed: "background1")
        
        playBackgroundMusic("backgroundMusic.mp3") // helper in MyUtils.swift
        
        // The position of the node in its parent's coordinate system.
        // The default value is (0.0, 0.0) === CGPointZero
        //background.position = CGPoint(x: size.width/2, y: size.height/2)
        // the default anchorPoint is (0.5, 0.5)

        // or use anchorPoint to do that
//        background.anchorPoint = CGPointZero
//        background.position = CGPointZero // Default
        
        // background.zRotation = CGFloat(M_PI) // M_PI == 180 degree == upside down
        // background.zRotation = CGFloat(M_PI) / 8  // M_PI/8 == 22.5 degree
        // rotated about the anchor point of the SpriteNode
        // refer following information for radian vs degree
        // http://math.rice.edu/~pcmi/sphere/drg_txt.html
     
        //
        // An endless scrolling background
        //
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            //background.position = CGPointZero
            background.position =
                CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            //background.zPosition = -1
            backgroundLayer.addChild(background)
        }

        //addChild(background)
        
        //let mySize = background.size
        //println("Size: \(mySize)")
        
        // adding a zombie sprite to the scene
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100 // larger z values are "out of screen"
        // zomebie.setScale(CGFloat(2)) // SKNode method: scale the node to 2x
        
        backgroundLayer.addChild(zombie)
        
        //
        // using the methods: start/stopZombieAnimation() to replace with
        //
        //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        //
        
        //debugDrawPlayableArea()
        
        //spwanEnemy()
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spwanEnemy),
                               SKAction.waitForDuration(enemySpawnDuration)])))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCat),
                               SKAction.waitForDuration(1.0)])))
        
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        //cat.removeFromParent()

        runAction(catCollisionSound)

        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        
        let turnGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        
        cat.runAction(turnGreen)
        
        //cat.runAction(SKAction.sequence([
        //    SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2),
        //    SKAction.colorizeWithColorBlendFactor(0.0, duration: 1.0)
        //    ])
        //)
        
        //runAction(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
        //println("zombieHitCat")
    }
    
    func loseCats() {
        var loseCount = 0
        
        /*
        enumerateChildNodesWithName(name: String) { (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void in
            code
        }
        */
        backgroundLayer.enumerateChildNodesWithName("train") { node, stop in
            
            var randomSpot = node.position
            
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            var group = SKAction.group( [
                            SKAction.rotateByAngle(CGFloat(M_PI) * 4.0, duration: 1.0),
                            SKAction.moveTo(randomSpot, duration: 1.0),
                            SKAction.scaleTo(0, duration: 1.0) ] )
            
            node.name = ""
            node.runAction(SKAction.sequence( [group, SKAction.removeFromParent()] ))
            
            loseCount++
            
            if loseCount >= 2 {
                stop.memory = true // break out of enumeration
            }
        }
    }
    
    func moveTrain() {
        
        var trainCount = 0
        
        var targetPosition = zombie.position
        
        backgroundLayer.enumerateChildNodesWithName("train") {
            node, _ in
            
            trainCount++
            
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position // a
                let direction = offset.normalized() // b
                let amountToMovePerSec = direction * self.catMovePointsPerSec // c
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration) // d
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration) // e
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
        
        //println("lives=\(lives), trainCount=\(trainCount)")
        
        if trainCount >= 10 && !gameOver {
            gameOver = true
            println("You win!")
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        //enemy.removeFromParent()
        
        runAction(enemyCollisionSound)
        
        loseCats()
        lives--
        
        isInvicible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        
        let blinkAction = SKAction.customActionWithDuration(duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
            //println("blink")
        }
        
        //let sequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove,
        //    reverseMove, logMessage, wait, reverseMid])
        //let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
        //let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])
        let wakeUpZombie = SKAction.runBlock() {
            self.isInvicible = false
            self.zombie.hidden = false
            //println("isInvicible = false")
        }

        zombie.runAction(SKAction.sequence([blinkAction, wakeUpZombie]))

        //runAction(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))
    }
    
    //runAction(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))

    func checkCollision() {
        var hitCats: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        if isInvicible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as SKSpriteNode
            if CGRectIntersectsRect(
                CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        
        cat.position = backgroundLayer.convertPoint(
            CGPoint(
                x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)),
                y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect))),
            fromNode: self)
        
        cat.setScale(0)
        backgroundLayer.addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)

        cat.zRotation = -π / 16.0  // 11.25°
        //let wait = SKAction.waitForDuration(10.0)
        
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        //let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        
        // a group action to run the wiggling and scaling at the same time
        let group = SKAction.group([fullScale, fullWiggle])
        
        let groupWait = SKAction.repeatAction(group, count: 10)

        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        let actions = [appear, groupWait, disappear, removeFromParent]
        
        cat.runAction(SKAction.sequence(actions))
    }
    
    func spwanEnemy() {
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"

        enemy.position = backgroundLayer.convertPoint(CGPoint(x: size.width + enemy.size.width/2,
            //y: size.height/2)
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                max: CGRectGetMaxY(playableRect) - enemy.size.height/2)),
            fromNode: self)
        
        backgroundLayer.addChild(enemy)
        
        let moveToPoint = backgroundLayer.convertPoint(
            CGPoint(x: -enemy.size.width/2, y: enemy.position.y),
            fromNode: self)
        
        let actionMove = SKAction.moveTo(moveToPoint, duration: enemySpawnDuration)
        let actionRemove = SKAction.removeFromParent()
        
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        //enemy.runAction(SKAction.sequence([actionMove]))
        
        // since SKAction.moveTo() is not reversable, use moveByX() to instead
        /*
        let actionMidMove = SKAction.moveTo(
            CGPoint(x: size.width/2,
                    y: CGRectGetMinY(playableRect) + enemy.size.height/2),
             duration: 1.0)
        let actionMove = SKAction.moveTo(CGPoint(x: -enemy.size.width/2,
                                                 y: enemy.position.y),
                                          duration: 1.0)
        */
        /*
        let actionMidMove = SKAction.moveByX(-size.width/2-enemy.size.width/2,
            y: -CGRectGetHeight(playableRect)/2, duration: 1.0)
        
        let actionMove = SKAction.moveByX(-size.width/2-enemy.size.width/2,
            y: CGRectGetHeight(playableRect)/2 - enemy.size.height/2, duration: 1.0)
        
        let logMessage = SKAction.runBlock() {
            println("Reached Bottom!")
        }
        
        let reverseMid = actionMidMove.reversedAction()
        let reverseMove = actionMove.reversedAction()
        
        let wait = SKAction.waitForDuration(0.25)
        
        //let sequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove,
        //    reverseMove, logMessage, wait, reverseMid])
        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
        let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])

        let repeat = SKAction.repeatActionForever(sequence)
        
        enemy.runAction(repeat)
        
//        enemy.runAction(sequence)
        
        // why the Enemy will bound when it hit the border but the zombie won't ????
        
        //let repeat = SKAction.repeatActionForever(seq)
        */
        
        
    }
    
    
    
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        // Velocity 速度. Vector 向量 = direction 方向 + magnitude 位移
        // 位移量 = 速度 * 時間
        //let amountToMove = CGPoint( x: velocity.x * CGFloat(dt),
        //                            y: velocity.y * CGFloat(dt))
        // using helper function
        let amountToMove = velocity * CGFloat(dt)
//        println("位移量: \(amountToMove)")
        //sprite.position = CGPoint(
        //    x: sprite.position.x + amountToMove.x,
        //    y: sprite.position.y + amountToMove.y)
        // using helper function
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {

        let offsetVector = location - zombie.position
        let length = offsetVector.length()
        let unitVecotr = offsetVector / CGFloat(length)
        velocityVector = unitVecotr * zombieMovePointsPerSec
        
        startZombieAnimation()  // 1234321234321....
        
    }
    
    func sceneTouched(touchLocation:CGPoint) {
//        println("sceneTouched:\(touchLocation)")
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    #if os(iOS)
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(backgroundLayer)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        //        println("touch.tapCount=\(touch.tapCount) in touchesMoved")
        //let touchLocation = touch.locationInNode(self)
        let touchLocation = touch.locationInNode(backgroundLayer)
        sceneTouched(touchLocation)
    }

    #else
    
    override func mouseDown(theEvent: NSEvent) {
        let touchLocation = theEvent.locationInNode(backgroundLayer)
        sceneTouched(touchLocation)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let touchLocation = theEvent.locationInNode(backgroundLayer)
        sceneTouched(touchLocation)
    }
    
    #endif
    
    
    func boundsCheckRombie() {
//        let bottomLeft = CGPointZero
//        let topRight = CGPoint(x: size.width, y: size.height)
        
        // compare background layer coordinates (zombie.position) to 
        // scene coordinates (such as CGPoint(x:0, y: CGRectGetMinY(playableRect))), 
        // which won’t work
        //let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let bottomLeft = backgroundLayer.convertPoint(
            CGPoint(x: 0, y: CGRectGetMinY(playableRect)),
            fromNode: self)
        //let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        let topRight = backgroundLayer.convertPoint(
            CGPoint(x: size.width, y: CGRectGetMaxY(playableRect)),
            fromNode: self)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocityVector.x = -velocityVector.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocityVector.x = -velocityVector.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocityVector.y = -velocityVector.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocityVector.y = -velocityVector.y
        }
    }
    
    /*
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let currentAngle:CGFloat = sprite.position.angle
        let targetAngle:CGFloat = direction.angle
        //sprite.zRotation = targetAngle // target angle
        let shortestAngle = shortestAngleBetween(currentAngle, targetAngle)
        println("shortestAngle=\(shortestAngle)")
        // let zombieRotateRadiansPerSec:CGFloat = 4.0 * π // 4π = 2π * 2 = 每秒轉兩圈
        var amountToRotate = shortestAngle * zombieRotateRadiansPerSec
        if shortestAngle < amountToRotate {
            amountToRotate = shortestAngle
        }
        
        //sprite.zRotation = amountToRotate.sign() // target angle
        sprite.zRotation = amountToRotate // target angle

    }
    */
    
    // copy from the answer !!!
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        // Your code here!
        let shortest = shortestAngleBetween(sprite.zRotation, velocityVector.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    // update FPS (Frame Per Second)
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        lastUpdateTime = currentTime
        //        println("\(dt*1000) milliseconds since last update")
        //        zombie1.position = CGPoint( x:zombie1.position.x + 4 ,
        //                                    y:zombie1.position.y)
        
//        var distance:CGFloat?
//        
//        if (lastTouchLocation == nil) {
//            distance = 100.0 // a bigger value
//        }
//        else {
//            distance = (lastTouchLocation! - zombie.position).length()
//        }
//        println("Distance=\(distance)")
//        let prospectiveMovement = CGFloat(dt) * zombieMovePointsPerSec
//        if distance <= prospectiveMovement {
//            moveSprite(zombie, velocity: CGPointZero)
//            println("lastTouchPosition:\(lastTouchLocation)-zombiePosition:\(zombie.position)  =  \(distance)")
//        }
//        else {
//            // Hook up to touch events
//            moveSprite(zombie, velocity: velocity)
//            rotateSprite(zombie, direction: velocity)
//        }

        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - zombie.position
            /*if diff.length() <= CGFloat(dt) * zombieMovePointsPerSec {
                zombie.position = lastTouchLocation!
                velocityVector = CGPointZero
                stopZombieAnimation()
            }
            else {*/
                // Hook up to touch events
                moveSprite(zombie, velocity: velocityVector)
                //let direction = velocity / 360.0
                //rotateSprite(zombie, direction: velocity)
                rotateSprite(zombie, direction: velocityVector,
                                     rotateRadiansPerSec: zombieRotateRadiansPerSec)
            //}
        }

        boundsCheckRombie()
        
        moveTrain()
        
        moveBackground()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            println("You lose!")
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)

            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)

        }
        
        //checkCollision()
        // using didEvaluateActions() instead
        //testUpdateCount++
        
        //println("updateCount:\(testUpdateCount) didEvaluateCount:\(testDidEvaluateActionsCount)")
        
        
    }
    
    override func didEvaluateActions() {
        //testDidEvaluateActionsCount++
        checkCollision()
        //println("didEvaluateActions")
    }
    
}
    

    
    






















