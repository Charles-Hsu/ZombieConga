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
    let zombie1 = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    var isFrozen: Bool = false
    let playableRect: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
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
        
        zombie1.position = CGPoint(x: 400, y: 400)
        zombie1.zPosition = 0
        // zomebie1.setScale(CGFloat(2)) // SKNode method: scale the node to 2x
        
        addChild(zombie1)
        
        debugDrawPlayableArea()
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        // Velocity 速度. Vector 向量 = direction 方向 + magnitude 位移
        // 位移量 = 速度 * 時間
        let amountToMove = CGPoint( x: velocity.x * CGFloat(dt),
                                    y: velocity.y * CGFloat(dt))
//        println("位移量: \(amountToMove)")
        sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y)
        
    }
    
    func moveZombieToward(location: CGPoint) {
        if isFrozen {
            velocity = CGPoint(x: 0, y: 0)
        }
        else {
//        println("moveZombieToward:\(location)")
        // the offset vector
        let offset = CGPoint(x: location.x - zombie1.position.x,
                             y: location.y - zombie1.position.y)
//        println("offset:\(offset)")
        // the length of the offset vector
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
//        println("length:\(length)")
        // the unit vector
        let direction = CGPoint(x: offset.x/CGFloat(length),
                                y: offset.y/CGFloat(length))
//        println("direction:\(direction)")
        // the velocity
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec,
                           y: direction.y * zombieMovePointsPerSec)
//        println("velocity:\(velocity)")
        }
        
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        println("sceneTouched:\(touchLocation)")
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        println("touch.tapCount=\(touch.tapCount) in touchesBegan")
        if touch.tapCount == 2 {
            isFrozen = true
        }
        else {
            isFrozen = false
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        println("touch.tapCount=\(touch.tapCount) in touchesMoved")
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func boundsCheckRombie() {
//        let bottomLeft = CGPointZero
//        let topRight = CGPoint(x: size.width, y: size.height)
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie1.position.x <= bottomLeft.x {
            zombie1.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie1.position.x >= topRight.x {
            zombie1.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie1.position.y <= bottomLeft.y {
            zombie1.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie1.position.y >= topRight.y {
            zombie1.position.y = topRight.y
            velocity.y = -velocity.y
        }
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
        
//        moveSprite(zombie1, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        // Hook up to touch events
        moveSprite(zombie1, velocity: velocity)
        boundsCheckRombie()
        
    }
    

    
    
}





















