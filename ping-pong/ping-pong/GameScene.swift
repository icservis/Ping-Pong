//
//  GameScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var ball: SKSpriteNode!
    var player: SKSpriteNode!
    var enemy: SKSpriteNode!
    var scoreLabel: SKLabelNode!

    let playPing = SKAction.playSoundFileNamed("ball-ping.caf", waitForCompletion: false)
    var score: (player: Int, enemy: Int) = (0, 0) {
        didSet {
            scoreLabel.text = "\(score.player) : \(score.enemy)"
        }
    }

    private lazy var sceneBorder: SKPhysicsBody = {
        let sceneBorder = SKPhysicsBody(edgeLoopFrom: frame)
        sceneBorder.friction = 0
        sceneBorder.restitution = 1
        sceneBorder.angularDamping = 0
        sceneBorder.linearDamping = 0
        return sceneBorder
    }()

    override func didMove(to view: SKView) {
        ball = (childNode(withName: "ball") as! SKSpriteNode)
        player = (childNode(withName: "player") as! SKSpriteNode)
        enemy = (childNode(withName: "enemy") as! SKSpriteNode)
        scoreLabel = (childNode(withName: "score") as! SKLabelNode)

        ball.physicsBody?.applyImpulse(CGVector(dx: 75, dy: 75))
        physicsBody = sceneBorder

        physicsWorld.contactDelegate = self
        let _ = playPing

        startGame()
    }

    func startGame() {
        score = (player: 0, enemy: 0)
    }

    func resetBall() {
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.position = CGPoint(x: 0, y: 0)
    }

    func addScore(playerWhoWon: SKSpriteNode) {
        if playerWhoWon == enemy {
            score.enemy += 1
        }
        if playerWhoWon == player {
            score.player += 1
        }
    }
    
    func touchDown(atPoint position : CGPoint) {
        let moveAction = SKAction.moveTo(x: position.x, duration: 0.1)
        player.run(moveAction)
    }
    
    func touchMoved(toPoint position : CGPoint) {
        let moveAction = SKAction.moveTo(x: position.x, duration: 0.1)
        player.run(moveAction)
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let followBall = SKAction.moveTo(x: ball.position.x, duration: 0.5)
        enemy.run(followBall)

        let offset: CGFloat = 70
        if ball.position.y <= player.position.y - offset {
            addScore(playerWhoWon: enemy)
            resetBall()
            ball.physicsBody?.applyImpulse(CGVector(dx: -75, dy: -75))
        }
        if ball.position.y >= enemy.position.y + offset {
            addScore(playerWhoWon: player)
            resetBall()
            ball.physicsBody?.applyImpulse(CGVector(dx: 75, dy: 75))
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard
            let spriteNodeA = contact.bodyA.node as? SKSpriteNode,
            let spriteNodeB = contact.bodyB.node as? SKSpriteNode
        else { return }

        let nodes: Set<SKSpriteNode> = [spriteNodeA, spriteNodeB]
        guard nodes.contains(ball) else { return }
        run(playPing)
    }

    func didEnd(_ contact: SKPhysicsContact) { }
}
