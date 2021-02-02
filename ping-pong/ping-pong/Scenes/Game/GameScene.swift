//
//  GameScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit

class GameScene: BaseScene {
    weak var controller: GameController?
    
    var ballSprite: SKSpriteNode!
    var playerSprite: SKSpriteNode!
    var enemySprite: SKSpriteNode!
    var playerScoreLabel: SKLabelNode!
    var enemyScoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var pauseResumeButton: ActionButton!

    let playPingAction = SKAction.playSoundFileNamed("ball-ping.caf", waitForCompletion: false)

    var startTime: TimeInterval = 0
    var currentTime: TimeInterval = 0 {
        didSet {
            if startTime == 0 { startTime = currentTime }
            timeLabel.text = timeIntervalFormatter.string(from: currentTime - startTime)
        }
    }

    lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.maximumUnitCount = 0
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()

    private lazy var sceneBorder: SKPhysicsBody = {
        let sceneBorder = SKPhysicsBody(edgeLoopFrom: frame)
        sceneBorder.friction = 0
        sceneBorder.restitution = 1
        sceneBorder.angularDamping = 0
        sceneBorder.linearDamping = 0
        return sceneBorder
    }()

    override func didMove(to view: SKView) {
        ballSprite = (childNode(withName: "ball") as! SKSpriteNode)
        playerSprite = (childNode(withName: "player") as! SKSpriteNode)
        enemySprite = (childNode(withName: "enemy") as! SKSpriteNode)

        playerScoreLabel = (childNode(withName: "playerScore") as! SKLabelNode)
        enemyScoreLabel = (childNode(withName: "enemyScore") as! SKLabelNode)

        timeLabel = (childNode(withName: "time") as! SKLabelNode)

        pauseResumeButton = (childNode(withName: "resume") as! ActionButton)
        pauseResumeButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            view.isPaused = true
            self.controller?.pauseGame { [unowned view] result in
                guard case .resume = result else { return }
                view.isPaused = false
            }
        }

        let impulse = CGVector(
            dx: CGFloat.random(in: 50...75),
            dy: CGFloat.random(in: 50...75)
        )
        ballSprite.physicsBody?.applyImpulse(impulse)
        physicsBody = sceneBorder

        physicsWorld.contactDelegate = self

        player.resetScore()
    }

    override func scoreChanged(_ score: Player.Score) {
        playerScoreLabel.text = "\(score.player)"
        enemyScoreLabel.text = "\(score.enemy)"
    }

    func resetBall() {
        ballSprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ballSprite.position = CGPoint(x: 0, y: 0)
    }

    func endGame(playerWhoWon: SKSpriteNode) {
        let randomX = Int.random(in: 50...75)
        let randomY = Int.random(in: 50...75)
        let radomSign = Bool.random() ? -1 : 1
        if playerWhoWon == enemySprite {
            guard player.increaseEnemysScore() else {
                self.gameOver()
                return
            }
            resetBall()
            let impulse = CGVector(dx: radomSign * randomX, dy: -randomY)
            ballSprite.physicsBody?.applyImpulse(impulse)
        }
        if playerWhoWon == playerSprite {
            guard player.increasePlayersScore() else {
                self.gameOver()
                return
            }
            resetBall()
            let impulse = CGVector(dx: radomSign * randomX, dy: randomY)
            ballSprite.physicsBody?.applyImpulse(impulse)
        }
    }

    private func gameOver() {
        view?.isPaused = true
        self.controller?.gameOver(
            score: player.score,
            time: currentTime - startTime
        ) { [weak self] result in
            self?.player.resetScore()
        }
    }
    
    func touchDown(atPoint position : CGPoint) {
        let moveAction = SKAction.moveTo(x: position.x, duration: 0.1)
        playerSprite.run(moveAction)
    }
    
    func touchMoved(toPoint position : CGPoint) {
        let moveAction = SKAction.moveTo(x: position.x, duration: 0.1)
        playerSprite.run(moveAction)
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
        self.currentTime = currentTime
        // Called before each frame is rendered
        let followBall = SKAction.moveTo(x: ballSprite.position.x, duration: 0.5)
        enemySprite.run(followBall)

        if ballSprite.position.y <= playerSprite.position.y {
            endGame(playerWhoWon: enemySprite)
        }
        if ballSprite.position.y >= enemySprite.position.y {
            endGame(playerWhoWon: playerSprite)
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
        guard nodes.contains(ballSprite) else { return }
        run(playPingAction)
    }

    func didEnd(_ contact: SKPhysicsContact) { }
}
