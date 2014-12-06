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
    let enemySpawnDuration = 5.0
    let zombieAnimation: SKAction
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocityVector = CGPointZero
    var isFrozen: Bool = false
    var lastTouchLocation: CGPoint?

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
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 0.4
        addChild(shape)
    }

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        
        // The position of the node in its parent's coordinate system.
        // The default value is (0.0, 0.0) === CGPointZero
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        // the default anchorPoint is (0.5, 0.5)

        // or use anchorPoint to do that
//        background.anchorPoint = CGPointZero
//        background.position = CGPointZero // Default
        
        // background.zRotation = CGFloat(M_PI) // M_PI == 180 degree == upside down
        // background.zRotation = CGFloat(M_PI) / 8  // M_PI/8 == 22.5 degree
        // rotated about the anchor point of the SpriteNode
        // refer following information for radian vs degree
        // http://math.rice.edu/~pcmi/sphere/drg_txt.html
     
        background.zPosition = -1
        
        addChild(background)
        
        let mySize = background.size
        println("Size: \(mySize)")
        
        // adding a zombie sprite to the scene
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 0
        // zomebie.setScale(CGFloat(2)) // SKNode method: scale the node to 2x
        
        addChild(zombie)
        zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        
        debugDrawPlayableArea()
        
        //spwanEnemy()
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spwanEnemy),
                               SKAction.waitForDuration(enemySpawnDuration)])))
        
    }
    
    
    func spwanEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2,
                                 //y: size.height/2)
                                 y: CGFloat.random(
                                    min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                                    max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(CGPoint(x: -enemy.size.width/2, y: enemy.position.y), duration: enemySpawnDuration)
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
        
    }
    
    func sceneTouched(touchLocation:CGPoint) {
//        println("sceneTouched:\(touchLocation)")
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
//        println("touch.tapCount=\(touch.tapCount) in touchesBegan")
//        if touch.tapCount == 2 {
//            isFrozen = true
//        }
//        else {
//            isFrozen = false
//        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
//        println("touch.tapCount=\(touch.tapCount) in touchesMoved")
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func boundsCheckRombie() {
//        let bottomLeft = CGPointZero
//        let topRight = CGPoint(x: size.width, y: size.height)
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
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
            //if diff.length() <= CGFloat(dt) * zombieMovePointsPerSec {
            //    zombie.position = lastTouchLocation!
            //    velocityVector = CGPointZero
            //}
            //else {
                // Hook up to touch events
                moveSprite(zombie, velocity: velocityVector)
                //let direction = velocity / 360.0
//                println("velocityVector:\(velocityVector)")
                //rotateSprite(zombie, direction: velocity)
                // rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat)
                rotateSprite(zombie, direction: velocityVector,
                                     rotateRadiansPerSec: zombieRotateRadiansPerSec)
            //}
        }

        boundsCheckRombie()
        
    }
    
}
    

    
    






















