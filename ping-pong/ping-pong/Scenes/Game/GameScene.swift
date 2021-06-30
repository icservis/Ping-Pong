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

    let playPingAction = SKAction.playSoundFileNamed("ball-ping.caf", waitForCompletion: false)
    let playTinkAction = SKAction.playSoundFileNamed("tink.m4a", waitForCompletion: false)
    let playTonkAction = SKAction.playSoundFileNamed("tonk.m4a", waitForCompletion: false)
    let playMatchWonAction = SKAction.playSoundFileNamed("matchWon.m4a", waitForCompletion: false)
    let playMatchLostAction = SKAction.playSoundFileNamed("matchLost.m4a", waitForCompletion: false)
    let playNotifyAction = SKAction.playSoundFileNamed("notify.m4a", waitForCompletion: false)

    var timer: Timer?
    lazy var currentTime : ElapsedTime = {
        let elapsedTime = ElapsedTime()
        elapsedTime.timeChangedBlock = { [weak self] time in
            guard let self = self else { return }
            DispatchQueue.global(qos: .default).async {
                let timeString = elapsedTime.string()
                DispatchQueue.main.async {
                    self.timeLabel.text = timeString
                }
            }
        }
        return elapsedTime
    }()

    private lazy var sceneBorder: SKPhysicsBody = {
        let sceneBorder = SKPhysicsBody(edgeLoopFrom: frame)
        sceneBorder.friction = 0
        sceneBorder.restitution = 1
        sceneBorder.angularDamping = 0
        sceneBorder.linearDamping = 0
        return sceneBorder
    }()

    private var gameIsPaused: Bool = false

    private var engine: CHHapticEngine!
    private var engineNeedsStart = true

    lazy var supportsHaptics: Bool = {
        return (UIApplication.shared.delegate as? AppDelegate)?.supportsHaptics ?? false
    }()

    struct Configuration {
        let maxVelocity: Double
        let minVelocity: Double
        let followBallDuration: Double
        let speedAcceleration: Double
        let randomYtoX: Double
    }

    static let minFollowBallDuration: TimeInterval = 0.1
    var configuration: Configuration {
        switch player.level {
        case .easy:
            return Configuration(
                maxVelocity: 75,
                minVelocity: 50,
                followBallDuration: 5 * Self.minFollowBallDuration,
                speedAcceleration: 0.5,
                randomYtoX: 10
            )
        case .medium:
            return Configuration(
                maxVelocity: 100,
                minVelocity: 75,
                followBallDuration: 3.333 * Self.minFollowBallDuration,
                speedAcceleration: 1,
                randomYtoX: 6.667
            )
        case .hard:
            return Configuration(
                maxVelocity: 125,
                minVelocity: 100,
                followBallDuration: 1.677 * Self.minFollowBallDuration,
                speedAcceleration: 2,
                randomYtoX: 3.333
            )
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

        physicsBody = sceneBorder
        physicsWorld.contactDelegate = self

        createAndStartHapticEngine()
    }

    func resetGame(level: Player.Difficulty) {
        player.set(level: level)
        restartGame(playerHasServis: true)
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
        let followBall = SKAction.moveTo(
            x: ballSprite.position.x,
            duration: configuration.followBallDuration
        )
        enemySprite.run(followBall)

        if ballSprite.position.y <= playerSprite.position.y {
            endGame(whoWon: enemySprite)
        }
        if ballSprite.position.y >= enemySprite.position.y {
            endGame(whoWon: playerSprite)
        }
    }

    //
    // MARK: Touches handling

    static let safeZoneLocationY: CGFloat = -350

    func touchDown(atPoint position : CGPoint) {
        let moveAction = SKAction.moveTo(x: position.x, duration: Self.minFollowBallDuration)
        playerSprite.run(moveAction)
    }
    
    func touchMoved(toPoint position : CGPoint) {
        let moveAction = SKAction.moveTo(x: position.x, duration: Self.minFollowBallDuration)
        playerSprite.run(moveAction)
    }
    
    func touchUp(atPoint pos : CGPoint) { }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = (t.location(in: self))
            guard location.y < Self.safeZoneLocationY else {
                super.touchesBegan(touches, with: event)
                return
            }
            self.touchDown(atPoint: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = (t.location(in: self))
            guard location.y < Self.safeZoneLocationY else {
                super.touchesMoved(touches, with: event)
                return
            }
            self.touchMoved(toPoint: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = (t.location(in: self))
            guard location.y < Self.safeZoneLocationY else {
                // super.touchesEnded(touches, with: event)
                pauseGame()
                return
            }
            self.touchUp(atPoint: location)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}
//
// Helpers
//

private extension GameScene {
    func pauseGame() {
        self.view?.isPaused = true
        self.controller?.pauseGame { [weak self] result in
            switch result {
            case .resume:
                self?.view?.isPaused = false
            case .restart:
                self?.restartGame(playerHasServis: true)
            case .mainMenu:
                break // paused
            }
        }
    }

    func restartGame(playerHasServis: Bool) {
        self.view?.isPaused = false

        self.player.resetScore()
        self.resetBall()
        self.resetPlayerPaddle()
        self.resetTime()

        self.controller?.loadCountDownTimer(
            initialCount: 3,
            tick: { [weak self] tick in
                guard let self = self else { return }
                if tick > 0 {
                    self.run(self.playTinkAction)
                } else {
                    self.run(self.playTonkAction)
                }

            },
            completion: { [weak self] in
            guard let self = self else { return }
            self.resetTimer(delay: 0) { [weak self] in
                guard let self = self else { return }
                let impulse = self.randomVector(positiveY: playerHasServis)
                self.ballSprite.physicsBody?.applyImpulse(impulse)
            }
        })
    }

    func endGame(whoWon: SKSpriteNode) {
        let impulse: CGVector
        self.resetBall()
        switch whoWon {
        case enemySprite:
            guard player.increaseEnemysScore() else {
                self.gameOver()
                return
            }
            impulse = randomVector(positiveY: false)
        case playerSprite:
            guard player.increasePlayersScore() else {
                self.gameOver()
                return
            }
            impulse = randomVector(positiveY: true)
        default:
            return
        }
        self.run(self.playNotifyAction)
        self.pauseTimer(delay: 1) { [weak self] in
            guard let self = self else { return }
            self.run(self.playTonkAction)
            self.ballSprite.physicsBody?.applyImpulse(impulse)
        }
    }

    func gameOver() {
        self.timer?.invalidate()
        let playerHasWon = self.player.score.player > self.player.score.enemy
        if playerHasWon {
            self.run(self.playMatchWonAction)
        } else {
            self.run(self.playMatchLostAction)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.view?.isPaused = true

            let result = GameResult(
                level: self.player.level,
                score: self.player.score,
                time: self.currentTime
            )
            self.controller?.gameOver(
                result: result
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .restart:
                    self.restartGame(playerHasServis: playerHasWon)
                case .mainMenu:
                    break;
                }
            }
        }
    }

    func resetTimer(delay: TimeInterval, completion: (() -> Void)?) {
        timer?.invalidate()
        resetTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(
                withTimeInterval: ElapsedTime.delta,
                repeats: true,
                block: { [weak self] timer in
                    guard
                        let self = self,
                        let view = self.view, !view.isPaused
                    else { return }
                    self.currentTime.update { [weak self] time in
                        guard let self = self else { return }
                        self.logger.trace("reset time update \(time)")
                        self.gameOver()
                    }
                }
            )
            completion?()
        }
    }

    func pauseTimer(delay: TimeInterval, completion: (() -> Void)?) {
        timer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(
                withTimeInterval: ElapsedTime.delta,
                repeats: true,
                block: { [weak self] timer in
                    guard
                        let self = self,
                        let view = self.view, !view.isPaused
                    else { return }
                    self.currentTime.update { [weak self] time in
                        guard let self = self else { return }
                        self.logger.trace("pause time update \(time)")
                        self.gameOver()
                    }
                }
            )
            completion?()
        }
    }

    func resetPlayerPaddle() {
        let centerPaddle = SKAction.moveTo(
            x: 0,
            duration: 0.5
        )
        playerSprite.run(centerPaddle)
    }

    func resetBall() {
        ballSprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ballSprite.position = CGPoint(x: 0, y: 0)
    }

    func resetTime() {
        self.timer?.invalidate()
        self.currentTime.reset()
    }

    func randomVector(positiveY: Bool) -> CGVector {
        let randomValue = Double.random(in: configuration.minVelocity...configuration.maxVelocity)
        let randomX = randomValue / configuration.randomYtoX
        let randomY = randomValue
        let randomSignX:Double = Bool.random() ? 1 : -1
        let randomSignY:Double = positiveY ? 1 : -1
        let vector = CGVector(
            dx: CGFloat(randomSignX * randomX),
            dy: CGFloat(randomSignY * randomY)
        )
        self.logger.trace("Random vector: \(vector)")
        return vector
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
            self.logger.debug("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                self.logger.trace("Audio session interrupt.")
            case .applicationSuspended:
                self.logger.trace("Application suspended.")
            case .idleTimeout:
                self.logger.trace("Idle timeout.")
            case .notifyWhenFinished:
                self.logger.trace("Finished.")
            case .systemError:
                self.logger.trace("System error.")
            case .engineDestroyed:
                self.logger.trace("Engine destroyed.")
            case .gameControllerDisconnect:
                self.logger.trace("Controller disconnected.")
            @unknown default:
                self.logger.trace("Unknown error")
            }

            // Indicate that the next time the app requires a haptic, the app must call engine.start().
            self.engineNeedsStart = true
        }

        // The reset handler notifies the app that it must reload all its content.
        // If necessary, it recreates all players and restarts the engine in response to a server restart.
        engine.resetHandler = {
            self.logger.debug("The engine reset --> Restarting now!")
            // Tell the rest of the app to start the engine the next time a haptic is necessary.
            self.engineNeedsStart = true
        }

        // Start haptic engine to prepare for use.
        do {
            try engine.start()

            // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
            engineNeedsStart = false
        } catch let error {
            self.logger.debug("The engine failed to start with error: \(error)")
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
            logger.debug("Haptic Playback Error: \(error)")
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
            let dx = CGFloat(configuration.maxVelocity) / CGFloat.random(in: (2...5))
            let signX: CGFloat = ballSprite.position.x < 0 ? 1 : -1
            let impulse = CGVector(
                dx: CGFloat(signX * dx),
                dy: 0
            )
            self.ballSprite.physicsBody?.applyImpulse(impulse)
        }

        if let dy = ballSprite.physicsBody?.velocity.dy, abs(dy) < 0.1 {
            let dy = CGFloat(configuration.maxVelocity) / CGFloat.random(in: (2...5))
            let signY: CGFloat = ballSprite.position.y < 0 ? 1 : -1
            let impulse = CGVector(
                dx: 0,
                dy: CGFloat(signY * dy)
            )
            self.ballSprite.physicsBody?.applyImpulse(impulse)
        }

        if supportsHaptics {
            self.playHapticResponse()
        } else {
            self.run(self.playPingAction)
        }

        let signY: Double = ballSprite.position.y < 0 ? 1 : -1
        let dy = CGFloat(signY * configuration.speedAcceleration)
        let impulse = CGVector(dx: 0, dy: dy)
        self.ballSprite.physicsBody?.applyImpulse(impulse)
    }

    func didEnd(_ contact: SKPhysicsContact) { }
}
