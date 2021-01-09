//
//  GameScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit

class GameScene: BaseScene {
    var ball: SKSpriteNode!
    var player: SKSpriteNode!
    var enemy: SKSpriteNode!
    var playerScore: SKLabelNode!
    var enemyScore: SKLabelNode!
    var pauseResume: ActionButton!

    let playPing = SKAction.playSoundFileNamed("ball-ping.caf", waitForCompletion: false)

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
        playerScore = (childNode(withName: "playerScore") as! SKLabelNode)
        enemyScore = (childNode(withName: "enemyScore") as! SKLabelNode)
        pauseResume = (childNode(withName: "resume") as! ActionButton)
        pauseResume.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.pauseGame()
        }

        let impulse = CGVector(dx: CGFloat.random(in: 50...75), dy: CGFloat.random(in: 50...75))
        ball.physicsBody?.applyImpulse(impulse)
        physicsBody = sceneBorder

        physicsWorld.contactDelegate = self
        let _ = playPing

        restoreScore()
    }

    override func updateScore() {
        super.updateScore()
        playerScore.text = "\(score.player)"
        enemyScore.text = "\(score.enemy)"
    }

    func resetBall() {
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.position = CGPoint(x: 0, y: 0)
    }

    func endGame(playerWhoWon: SKSpriteNode) {
        let randomX = Int.random(in: 50...75)
        let randomY = Int.random(in: 50...75)
        let radomSign = Bool.random() ? -1 : 1
        if playerWhoWon == enemy {
            score.enemy += 1
            resetBall()
            let impulse = CGVector(dx: radomSign * randomX, dy: -randomY)
            ball.physicsBody?.applyImpulse(impulse)
        }
        if playerWhoWon == player {
            score.player += 1
            resetBall()
            let impulse = CGVector(dx: radomSign * randomX, dy: randomY)
            ball.physicsBody?.applyImpulse(impulse)
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

        if ball.position.y <= player.position.y {
            endGame(playerWhoWon: enemy)
        }
        if ball.position.y >= enemy.position.y {
            endGame(playerWhoWon: player)
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
