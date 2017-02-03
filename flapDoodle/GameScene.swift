//
//  GameScene.swift
//  flapDoodle
//
//  Created by Amber Blue on 2/1/17.
//  Copyright (c) 2017 Amber Blue. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Ship : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Ship = SKSpriteNode()
    
    var wallPair = SKNode()

    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLbl = SKLabelNode()
    
    var died = Bool()
    
    var restartBTN = SKSpriteNode()
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
    
//        print(UIFont.familyNames())
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2{
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            self.addChild(background)
        }
        

        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
//        scoreLbl.fontName = "the unseen"
        scoreLbl.fontSize = 60
        scoreLbl.fontColor = SKColor.redColor()
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Ship
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ship
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        Ship = SKSpriteNode(imageNamed: "Ship")
        Ship.size = CGSize(width: 95, height: 75)
        Ship.position = CGPoint(x: frame.width / 2 - Ship.frame.width, y: self.frame.height / 2)
        
        Ship.physicsBody = SKPhysicsBody(circleOfRadius: Ship.frame.height / 2)
        Ship.physicsBody?.categoryBitMask = PhysicsCategory.Ship
        Ship.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Ship.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Ship.physicsBody?.affectedByGravity = false
        Ship.physicsBody?.dynamic = true
        
        Ship.zPosition = 2
        
        self.addChild(Ship)

    
    }
    
    
    override func didMoveToView(view: SKView) {
        
        createScene()
    
    }
    func createBTN(){
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSizeMake(200,100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        
        self.addChild(restartBTN)
        
        runAction(SKAction.playSoundFileNamed("die.mp3", waitForCompletion: false))
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))
    }
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Ship{
            
            score += 1
            scoreLbl.text = "\(score)"
            runAction(SKAction.playSoundFileNamed("ruby.wav", waitForCompletion: false))
            firstBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Ship && secondBody.categoryBitMask == PhysicsCategory.Score {
            
            score += 1
            scoreLbl.text = "\(score)"
            runAction(SKAction.playSoundFileNamed("ruby.wav", waitForCompletion: false))
            secondBody.node?.removeFromParent()
            
        }
            
        else if firstBody.categoryBitMask == PhysicsCategory.Ship && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Ship{
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Ship && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Ship{
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
        }
        
        
        
        
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if gameStarted == false{
            
            gameStarted = true
            
            Ship.physicsBody?.affectedByGravity = true

            let spawn = SKAction.runBlock({
                () in
                
                self.createWalls()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ship.physicsBody?.velocity = CGVectorMake(0,0)
            Ship.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            

            
        }
        else{
            
            if died == true{
                
            }
            else{
            Ship.physicsBody?.velocity = CGVectorMake(0,0)
            Ship.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            }
            
        }
        
        
        for touch in touches{
            
            let location = touch.locationInNode(self)
            if died == false {
                 runAction(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
            }
           

            if died == true{
                if restartBTN.containsPoint(location){
                    restartScene()
                }
            }
        }
        

}

    
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "Ruby")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Score
//        scoreNode.color = SKColor.blueColor()
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        
        let topWall = SKSpriteNode(imageNamed: "wall")
        let bottWall = SKSpriteNode(imageNamed: "wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + 350)
        bottWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        bottWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Ship
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ship
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.dynamic = false
        
        bottWall.physicsBody = SKPhysicsBody(rectangleOfSize: bottWall.size)
        bottWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottWall.physicsBody?.collisionBitMask = PhysicsCategory.Ship
        bottWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ship
        bottWall.physicsBody?.affectedByGravity = false
        bottWall.physicsBody?.dynamic = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.runAction(moveAndRemove)
        
        wallPair.addChild(scoreNode)
        
        self.addChild(wallPair)
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
