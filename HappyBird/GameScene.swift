//
//  GameScene.swift
//  HappyBird
//
//  Created by PH Soria on 25/09/2017.
//  Copyright © 2017 Pierre-Henry Soria. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let birdTimePerFrame = 0.1
    let maxTimeBgMoving: CGFloat = 3

    var bird: SKSpriteNode = SKSpriteNode()
    var background: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKLabelNode = SKLabelNode()
    var score: Int = 0
    var gameOver = false
    var gameOverLabel: SKLabelNode = SKLabelNode()
    var timer: Timer = Timer()

    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        setUpGame()

    }

    func setUpGame() -> Void {
        timer = Timer.scheduledTimer(
            timeInterval: 3,
             target: self,
             selector: #selector(self.drawPipes),
             userInfo: nil,
             repeats: true
        )

        drawBackground()
        drawBird()
        drawPipes()
    }

    func drawBird() -> Void {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")

        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: birdTimePerFrame)
        let makeBirdFlap = SKAction.repeatForever(animation)

        bird = SKSpriteNode(texture: birdTexture)

        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)

        // For colisions
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)

        bird.physicsBody!.isDynamic = false

        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue

        self.addChild(bird)

        // TODO Has to be moved into a func
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))

        ground.physicsBody!.isDynamic = false

        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue

        self.addChild(ground)

        self.setScoreStyle()

        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        self.addChild(scoreLabel)
    }

    func drawBackground() -> Void {
        let bgTexture = SKTexture(imageNamed: "background.png")

        let moveBgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBgAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let bgAnimation = SKAction.sequence([moveBgAnimation, shiftBgAnimation])
        let moveBgForever = SKAction.repeatForever(bgAnimation)

        var i: CGFloat = 0

        while i < maxTimeBgMoving {
            background = SKSpriteNode(texture: bgTexture)
            background.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            background.size.height = self.frame.height
            background.run(moveBgForever)

            self.addChild(background)

            i += 1

            // Set background first
            background.zPosition = -2
        }
    }

    // Draws the pipes and move them around the bird
    @objc func drawPipes() -> Void {
        let gapHeight = bird.size.height * 4

        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()

        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])

        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4

        makePipe1(moveAndRemovePipes, gapHeight, pipeOffset)
        makePipe2(moveAndRemovePipes, gapHeight, pipeOffset)
        makeGap(moveAndRemovePipes, gapHeight, pipeOffset)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
            if  contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue ||
                contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scoreLabel.text = String(score)
            } else {
                resetGame()

                setMessageScoreStyle()
                gameOverLabel.text = "Game Over! :-("
                gameOverLabel.position = CGPoint(x: self.frame.midY, y: self.frame.midY)
                self.addChild(gameOverLabel)
            }
        }
    }

    func makePipe1(_ moveAndRemovePipes: SKAction, _ gapHeight: CGFloat, _ pipeOffset: CGFloat) -> Void {
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)

        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false

        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        setPipePosition(pipe1)

        self.addChild(pipe1)
    }

    func makePipe2(_ moveAndRemovePipes: SKAction, _ gapHeight: CGFloat, _ pipeOffset: CGFloat) -> Void {
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2  + pipeOffset)
        pipe2.run(moveAndRemovePipes)

        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody!.isDynamic = false

        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        setPipePosition(pipe2)

        self.addChild(pipe2)
    }

    // Set the pipe second position after background
    func setPipePosition(_ pipe: SKSpriteNode) -> Void {
        pipe.zPosition = -1
    }

    func makeGap(_ moveAndRemovePipes: SKAction, _ gapHeight: CGFloat, _ pipeOffset: CGFloat) -> Void {
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")

        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))

        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipes)

        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Gap.rawValue

        self.addChild(gap)
    }

    func setScoreStyle() -> Void {
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 80
        scoreLabel.text = "0"
    }

    func setMessageScoreStyle() -> Void {
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Void {
        if gameOver == false {
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            startGame()
            removeAllChildren()
            setUpGame()
        }
    }

    func startGame() -> Void {
        gameOver = false
        score = 0
        self.speed = 1
    }

    func resetGame() -> Void {
        self.speed = 0
        gameOver = true
        timer.invalidate()
    }
}
