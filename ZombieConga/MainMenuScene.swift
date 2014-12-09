//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Charles Hsu on 12/8/14.
//  Copyright (c) 2014 Loxoll. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        var background: SKSpriteNode
        background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
    }
    
    #if os(iOS)
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        sceneTapped()
    }
    
    #else
    
    override func mouseDown(theEvent: NSEvent) {
        sceneTapped()
    }
    
    #endif
    
    //let scene = GameScene(size:CGSize(width: 2048, height: 1536))

    func sceneTapped() {
        let gameScene = GameScene(size:CGSize(width: self.size.width, height: self.size.height))
        
        gameScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsOpenHorizontalWithDuration(1.5)
        view?.presentScene(gameScene, transition: reveal)

    }
    
}
