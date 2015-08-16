import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    // code connections
    weak var character: Character!
    weak var obstaclesNode: CCNode!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var scoreLabel: CCLabelTTF!
    
    var obstacleArray: [Obstacle] = [] // var obstacleArray = [Obstacle]()
    var obstacleWidth: CGFloat = 30
    var initialObstacleXPos: CGFloat = 200
    var spaceBetweenObstacles: CGFloat = 150
    var obstacleScrollSpeed: CGFloat = 50
    
    var sinceTouch: CCTime = 0
    var score: Int = 0 {
        didSet {
            animationManager.runAnimationsForSequenceNamed("ScoreIncreased")
            scoreLabel.string = "\(score)"
        }
    }
    
    // create obstacles when MainScene is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
        loadObstacles(3)
    }
    
    // override touch controls
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        character.physicsBody.applyImpulse(CGPoint(x: 0, y: 200))
        character.physicsBody.applyAngularImpulse(8000)
        sinceTouch = 0
    }
    
    // used to update the positions of the obstacles on the screen
    override func update(delta: CCTime) {
        sinceTouch += delta
        
        character.position.x = 60
        
        // clamp vertical velocity
        let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        character.physicsBody.velocity = CGPoint(x: 0, y: CGFloat(velocityY))
        
        // clamp character rotation
        character.rotation = clampf(character.rotation, -30, 90)
        if character.physicsBody.allowsRotation {
            let angularVelocity = clampf(Float(character.physicsBody.angularVelocity), -2, 1)
            character.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        // apply strong downward rotation impulse if the
        // player hasn't touched the screen in 0.4 seconds
        if sinceTouch > 0.4 {
            let impulse = -10000.0 * delta
            character.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        // move all the obstacles backwards
        for obstacle in obstacleArray {
            obstacle.position.x -= obstacleScrollSpeed * CGFloat(delta)
        }
        
        if obstacleArray.first!.position.x <= -obstacleWidth/2 {
            generateNewObstacle()
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
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, character: CCNode!, goal: CCNode!) -> ObjCBool {
        goal.removeFromParent()
        score++
        return true
    }
}
