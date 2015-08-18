import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // code connections
    weak var character: Character!
    weak var obstaclesNode: CCNode!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var scoreLabel: CCLabelTTF!
    weak var restartButton: CCButton!
    weak var gameOverNode: CCNode!
    weak var gameOverScoreLabel: CCLabelTTF!
    weak var bestScoreLabel: CCLabelTTF!
    
    // obstacle variables
    var obstacleArray: [Obstacle] = [] // var obstacleArray = [Obstacle]()
    var obstacleWidth: CGFloat = 30
    var initialObstacleXPos: CGFloat = 300
    var spaceBetweenObstacles: CGFloat = 160
    var obstacleScrollSpeed: CGFloat = 80
    
    var screenHeight = CCDirector.sharedDirector().viewSize().height
    var sinceTouch: CCTime = 0
    var gameOver: Bool = false
    var characterInScreen: Bool = true
    var score: Int = 0 {
        didSet {
            animationManager.runAnimationsForSequenceNamed("ScoreIncreased")
            scoreLabel.string = "\(score)"
            gameOverScoreLabel.string = "\(score)"
        }
    }
    
    // create obstacles when MainScene is loaded
    func didLoadFromCCB() {
        println(screenHeight)
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
        loadObstacles(3)
    }
    
    // override touch controls
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if !gameOver && characterInScreen {
            character.physicsBody.applyImpulse(CGPoint(x: 0, y: 200))
            character.physicsBody.applyAngularImpulse(8000)
            sinceTouch = 0
        }
    }
    
    // used to update the positions of the obstacles on the screen
    override func update(delta: CCTime) {
        if !gameOver {
            sinceTouch += delta
            
            character.position.x = 60

            if character.position.y < 1 {
                // clamp vertical velocity
                characterInScreen = true
                let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(CGFloat.max), 200)
                character.physicsBody.velocity = CGPoint(x: 0, y: CGFloat(velocityY))
                
            }
            else {
                characterInScreen = false
                character.physicsBody.velocity.y = -40
            }
            
            // clamp character rotation
            character.rotation = clampf(character.rotation, -30, 80)
            if character.physicsBody.allowsRotation {
                let angularVelocity = clampf(Float(character.physicsBody.angularVelocity), -2, 1)
                character.physicsBody.angularVelocity = CGFloat(angularVelocity)
            }
            
            // apply strong downward rotation impulse if the
            // player hasn't touched the screen in 0.4 seconds
            if sinceTouch > 0.35 {
                let impulse = -1000.0 * delta
                character.physicsBody.applyAngularImpulse(CGFloat(impulse))
            }
            
            // move all the obstacles backwards
            for obstacle in obstacleArray {
                obstacle.position.x -= obstacleScrollSpeed * CGFloat(delta)
            }
            
            // generate a new obstacle when the first 
            // obstacle in the array leaves the scene
            if obstacleArray.first!.position.x <= -obstacleWidth/2 {
                generateNewObstacle()
            }
        }
        else {
            character.physicsBody.velocity.x = 0
        }
    }
        
    // load initial obstacles that are evenly spaced and have random y positions
    func loadObstacles(number: Int) {
        for i in 0..<number {
            println(i)
            var obstacle = CCBReader.load("Obstacle") as! Obstacle
            obstacle.position.x = initialObstacleXPos + CGFloat(i) * spaceBetweenObstacles
            obstaclesNode.addChild(obstacle)
            obstacleArray.append(obstacle)
        }
    }
    
    // create and position a new obstacle in the scene
    func generateNewObstacle() {
        let newObstacle = CCBReader.load("Obstacle") as! Obstacle
        newObstacle.position.x = obstacleArray.last!.position.x + spaceBetweenObstacles
        
        obstacleArray.removeAtIndex(0).removeFromParent()
        obstacleArray.append(newObstacle)
        obstaclesNode.addChild(newObstacle)
    }
    
    // restart button selector
    func restart() {
        CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("MainScene"))
    }
    
    func setHighScore() {
        var highscore = defaults.integerForKey("highscore")
        if score > highscore {
            defaults.setInteger(score, forKey: "highscore")
        }
        var newHighscore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        bestScoreLabel.string = "\(newHighscore)"
    }
    
    // collision handling functions
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, character: CCNode!, goal: CCNode!) -> ObjCBool {
        goal.removeFromParent()
        score++
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, character: CCNode!, obstacle: CCNode!) -> ObjCBool {
        gameOver = true
        setHighScore()
        scoreLabel.visible = false
        gameOverNode.visible = true
        return true
    }
}
