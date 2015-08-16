import Foundation

class MainScene: CCNode {
    
    // code connections
    weak var character: CCSprite!
    weak var obstaclesNode: CCNode!
    weak var gamePhysicsNode: CCPhysicsNode!
    
//    var obstacleArray = [Obstacle]()
    var obstacleArray: [Obstacle] = []
    var initialObstacleXPos = 200
    var spaceBetweenObstacles = 150
    
    var sinceTouch: CCTime = 0
    
    // create obstacles when MainScene is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true
        loadObstacles(10)
    }
    
    // override touch controls
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        character.physicsBody.applyImpulse(CGPoint(x: 0, y: 200))
        character.physicsBody.applyAngularImpulse(10000)
        sinceTouch = 0
    }
    
    // used to update the positions of the obstacles on the screen
    override func update(delta: CCTime) {
        sinceTouch += delta
        
        // clamp vertical velocity
        let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        character.physicsBody.velocity = CGPoint(x: 0, y: CGFloat(velocityY))
        
        // clamp character rotation
        character.rotation = clampf(character.rotation, -30, 90)
        if character.physicsBody.allowsRotation {
            let angularVelocity = clampf(Float(character.physicsBody.angularVelocity), -2, 1)
            character.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        // apply strong downward rotation impulse if the player hasn't touched
        // the screen in 0.4 seconds
        if sinceTouch > 0.4 {
            let impulse = -18000.0 * delta
            character.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
    }
    
    // load initial obstacles that are evenly spaced out and have random y positions
    func loadObstacles(number: Int) {
        for i in 0..<number {
            println(i)
            var randYPos = arc4random_uniform(408) + 80
            var obstacle = CCBReader.load("Obstacle") as! Obstacle
            obstacle.position.x = CGFloat(initialObstacleXPos + i * spaceBetweenObstacles)
            obstacle.position.y = CGFloat(randYPos)
            obstaclesNode.addChild(obstacle)
            obstacleArray.append(obstacle)
        }
    }
    
}
