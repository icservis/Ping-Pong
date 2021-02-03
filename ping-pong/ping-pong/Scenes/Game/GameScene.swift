//
//  GameScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import CoreHaptics

class GameScene: BaseScene {
    weak var controller: GameController?
    
    var ballSprite: SKSpriteNode!
    var playerSprite: SKSpriteNode!
    var enemySprite: SKSpriteNode!
    var playerScoreLabel: SKLabelNode!
    var enemyScoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
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

    private var engine: CHHapticEngine!
    private var engineNeedsStart = true

    lazy var supportsHaptics: Bool = {
        return (UIApplication.shared.delegate as? AppDelegate)?.supportsHaptics ?? false
    }()

    struct Configuration {
        let maxVelocity: Int
        let minVelocity: Int
        let followBallDuration: TimeInterval
    }

    var configuration: Configuration {
        switch player.level {
        case .easy:
            return Configuration(maxVelocity: 75, minVelocity: 50, followBallDuration: 0.5)
        case .medium:
            return Configuration(maxVelocity: 100, minVelocity: 75, followBallDuration: 0.3)
        case .hard:
            return Configuration(maxVelocity: 150, minVelocity: 100, followBallDuration: 0.2)
        }
    }

    override func didMove(to view: SKView) {
        ballSprite = (childNode(withName: "ball") as! SKSpriteNode)
        playerSprite = (childNode(withName: "player") as! SKSpriteNode)
        enemySprite = (childNode(withName: "enemy") as! SKSpriteNode)

        playerScoreLabel = (childNode(withName: "playerScore") as! SKLabelNode)
        enemyScoreLabel = (childNode(withName: "enemyScore") as! SKLabelNode)

        timeLabel = (childNode(withName: "time") as! SKLabelNode)
        levelLabel = (childNode(withName: "level") as! SKLabelNode)

        pauseResumeButton = (childNode(withName: "resume") as! ActionButton)
        pauseResumeButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            view.isPaused = true
            self.controller?.pauseGame { [weak self, unowned view] result in
                switch result {
                case .resume:
                    view.isPaused = false
                case .restart:
                    self?.restartGame()
                case .mainMenu:
                    break
                }
            }
        }

        physicsBody = sceneBorder
        physicsWorld.contactDelegate = self

        createAndStartHapticEngine()
    }

    private func restartGame() {
        player.resetScore()
        resetBall()
        setTimer()
        view?.isPaused = false
        let impulse = randomVector(positiveY: true)
        ballSprite.physicsBody?.applyImpulse(impulse)
    }

    func resetGame(level: Player.Difficulty) {
        player.set(level: level)
        restartGame()
    }

    func resetBall() {
        ballSprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ballSprite.position = CGPoint(x: 0, y: 0)
    }

    func resetTime() {
        self.currentTime = 0
        self.timeLabel.text = self.elapsedTimeFormatter.string(from: self.currentTime)
    }

    override func scoreChanged(_ score: Player.Score) {
        playerScoreLabel.text = "\(score.player)"
        enemyScoreLabel.text = "\(score.enemy)"
    }

    override func levelChanged(_ level: Player.Difficulty) {
        levelLabel.text = level.description
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let followBall = SKAction.moveTo(x: ballSprite.position.x, duration: configuration.followBallDuration)
        enemySprite.run(followBall)

        if ballSprite.position.y <= playerSprite.position.y {
            endGame(playerWhoWon: enemySprite)
        }
        if ballSprite.position.y >= enemySprite.position.y {
            endGame(playerWhoWon: playerSprite)
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
}
//
// Helpers
//

private extension GameScene {
    func setTimer() {
        resetTime()
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

    func gameOver() {
        view?.isPaused = true
        timer?.invalidate()
        self.controller?.gameOver(
            score: player.score,
            time: currentTime
        ) { [weak self] result in
            guard let self = self else { return }
            let playerHasWon = self.player.score.player > self.player.score.enemy
            self.player.resetScore()
            self.resetBall()
            self.resetTime()

            guard case .restart = result else { return }
            self.setTimer()
            self.view?.isPaused = false

            let impulse = self.randomVector(positiveY: playerHasWon)
            self.ballSprite.physicsBody?.applyImpulse(impulse)
        }
    }

    func randomVector(positiveY: Bool) -> CGVector {
        let randomX = Int.random(in: configuration.minVelocity...configuration.maxVelocity)
        let randomY = Int.random(in: configuration.minVelocity...configuration.maxVelocity)
        let randomSignX = Bool.random() ? 1 : -1
        let randomSignY = positiveY ? 1 : -1
        return CGVector(
            dx: randomSignX * randomX,
            dy: randomSignY * randomY
        )
    }
}

//
// Haptics
//

private extension GameScene {
    func createAndStartHapticEngine() {
        guard supportsHaptics else { return }

        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine()
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }

        // The stopped handler alerts engine stoppage.
        engine.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                debugPrint("Audio session interrupt.")
            case .applicationSuspended:
                debugPrint("Application suspended.")
            case .idleTimeout:
                debugPrint("Idle timeout.")
            case .notifyWhenFinished:
                debugPrint("Finished.")
            case .systemError:
                debugPrint("System error.")
            case .engineDestroyed:
                debugPrint("Engine destroyed.")
            case .gameControllerDisconnect:
                debugPrint("Controller disconnected.")
            @unknown default:
                debugPrint("Unknown error")
            }

            // Indicate that the next time the app requires a haptic, the app must call engine.start().
            self.engineNeedsStart = true
        }

        // The reset handler notifies the app that it must reload all its content.
        // If necessary, it recreates all players and restarts the engine in response to a server restart.
        engine.resetHandler = {
            print("The engine reset --> Restarting now!")

            // Tell the rest of the app to start the engine the next time a haptic is necessary.
            self.engineNeedsStart = true
        }

        // Start haptic engine to prepare for use.
        do {
            try engine.start()

            // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
            engineNeedsStart = false
        } catch let error {
            print("The engine failed to start with error: \(error)")
        }
    }

    func playHapticResponse() {
        // Play haptic here.
        do {
            // Start the engine if necessary.
            if engineNeedsStart {
                try engine.start()
                engineNeedsStart = false
            }

            // Map the bounce velocity to intensity & sharpness.
            guard let velocity = ballSprite.physicsBody?.velocity else { return }
            let xVelocity = Float(velocity.dx)
            let yVelocity = Float(velocity.dy)

            // Normalize magnitude to map one number to haptic parameters:
            let magnitude = sqrtf(xVelocity * xVelocity + yVelocity * yVelocity)
            let normalizedMagnitude = min(max(magnitude / (10 * Float(configuration.maxVelocity)), 0.0), 1.0)

            // Create a haptic pattern player from normalized magnitude.
            let hapticPlayer = try playerForMagnitude(normalizedMagnitude)

            // Start player, fire and forget
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch let error {
            print("Haptic Playback Error: \(error)")
        }
    }

    func playerForMagnitude(_ magnitude: Float) throws -> CHHapticPatternPlayer? {
        let volume: Float = linearInterpolation(alpha: magnitude, min: 0.5, max: 1)
        let decay: Float = linearInterpolation(alpha: magnitude, min: 0.0, max: 0.1)
        let audioEvent = CHHapticEvent(
            eventType: .audioContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .audioPitch, value: -0.15),
                CHHapticEventParameter(parameterID: .audioVolume, value: volume),
                CHHapticEventParameter(parameterID: .decayTime, value: decay),
                CHHapticEventParameter(parameterID: .sustained, value: 0)
            ],
            relativeTime: 0
        )

        let sharpness = linearInterpolation(alpha: magnitude, min: 0.9, max: 0.5)
        let intensity = linearInterpolation(alpha: magnitude, min: 0.375, max: 1.0)
        let hapticEvent = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            ],
            relativeTime: 0
        )

        let pattern = try CHHapticPattern(events: [audioEvent, hapticEvent], parameters: [])
        return try engine.makePlayer(with: pattern)
    }

    private func linearInterpolation(alpha: Float, min: Float, max: Float) -> Float {
        return min + alpha * (max - min)
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

        if let dx = ballSprite.physicsBody?.velocity.dx, abs(dx) < 0.1 {
            let dx = Float(configuration.maxVelocity) / Float.random(in: (10...25))
            let signX: Float = ballSprite.position.x < 0 ? 1 : -1
            let impulse = CGVector(
                dx: Int(signX * dx),
                dy: 0
            )
            self.ballSprite.physicsBody?.applyImpulse(impulse)
        }

        if let dy = ballSprite.physicsBody?.velocity.dy, abs(dy) < 0.1 {
            let dy = Float(configuration.maxVelocity) / Float.random(in: (10...25))
            let signY: Float = ballSprite.position.y < 0 ? 1 : -1
            let impulse = CGVector(
                dx: 0,
                dy: Int(signY * dy)
            )
            self.ballSprite.physicsBody?.applyImpulse(impulse)
        }

        if supportsHaptics {
            playHapticResponse()
        } else {
            run(playPingAction)
        }
    }

    func didEnd(_ contact: SKPhysicsContact) { }
}
