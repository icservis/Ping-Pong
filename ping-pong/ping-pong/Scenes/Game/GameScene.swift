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

    var timer: Timer?
    var currentTime: TimeInterval = 0
    let delta: TimeInterval = 0.1

    lazy var elapsedTimeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.allowsFloats = true

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

    func randomVector(positiveY: Bool) -> CGVector {
        let randomX = Int.random(in: 50...75)
        let randomY = Int.random(in: 50...75)
        let randomSignX = Bool.random() ? 1 : -1
        let randomSignY = positiveY ? 1 : -1
        return CGVector(
            dx: randomSignX * randomX,
            dy: randomSignY * randomY
        )
    }

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

        let impulse = randomVector(positiveY: true)
        ballSprite.physicsBody?.applyImpulse(impulse)
        physicsBody = sceneBorder

        physicsWorld.contactDelegate = self

        player.resetScore()
        setTimer()
    }

    private func setTimer() {
        self.timer = Timer.scheduledTimer(
            withTimeInterval: delta,
            repeats: true,
            block: { [weak self] timer in
                guard let self = self, let view = self.view, !view.isPaused else { return }
                self.currentTime = self.currentTime + self.delta

                DispatchQueue.global(qos: .default).async {
                    let timeString = self.elapsedTimeFormatter.string(from: self.currentTime)
                    DispatchQueue.main.async {
                        self.timeLabel.text = timeString
                    }
                }
            }
        )
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
        if playerWhoWon == enemySprite {
            guard player.increaseEnemysScore() else {
                self.gameOver()
                return
            }
            resetBall()
            let impulse = randomVector(positiveY: false)
            ballSprite.physicsBody?.applyImpulse(impulse)
        }
        if playerWhoWon == playerSprite {
            guard player.increasePlayersScore() else {
                self.gameOver()
                return
            }
            resetBall()
            let impulse = randomVector(positiveY: true)
            ballSprite.physicsBody?.applyImpulse(impulse)
        }
    }

    private func gameOver() {
        view?.isPaused = true
        timer?.invalidate()
        self.controller?.gameOver(
            score: player.score,
            time: currentTime
        ) { [weak self] result in
            guard let self = self else { return }
            self.player.resetScore()
            self.view?.isPaused = false
            self.resetBall()
            let impulse = self.randomVector(positiveY: true)
            self.ballSprite.physicsBody?.applyImpulse(impulse)
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
