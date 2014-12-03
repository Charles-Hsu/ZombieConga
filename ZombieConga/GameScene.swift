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
    let zombieMovePointsPerSecInXDirection: CGFloat = 480.0
    
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
        
        moveSprite(zombie1, velocity: CGPoint(x: zombieMovePointsPerSecInXDirection, y: 0))
        
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
    
    
    
    
    
}
