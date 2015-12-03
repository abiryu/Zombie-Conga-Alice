import SpriteKit
class GameScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "background1")
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    var invincible: Bool = false
    let catMovePointsPerSecond : CGFloat = 480.0
    

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3 
            playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight) // 4
        //1
        var textures:[SKTexture] = []
        //2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        //3
        textures.append(textures[2])
        textures.append(textures[1])
        
        //4
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        super.init(size: size) // 5
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)

    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
    //let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        //zombie.setScale(2)
    addChild(background)
        background.zPosition = -1
    addChild(zombie)
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([SKAction.runBlock(spawnCat),
        SKAction.waitForDuration(1.0)])))
        zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(2.0)])))
    debugDrawPlayableArea()
    }
    
    
    override func update(currentTime: NSTimeInterval) {

        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouch = lastTouchLocation {
        let diff = lastTouch - zombie.position
        if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
          zombie.position = lastTouchLocation!
            velocity = CGPointZero
            stopZombieAnimation()
        } else {
            moveSprite(zombie, velocity: velocity)
            rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
    }
        
        boundsCheckZombie()
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        //checkCollisions()
        moveTrain()
        

    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
         //1
        let amountToMove = velocity * CGFloat(dt)
         //2
        sprite.position += amountToMove
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
    }

    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }

    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0,
            y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width,
            y: CGRectGetMaxY(playableRect))

        //println("size width: \(size.width) ")
        //println("size height: \(size.height) ")

        if zombie.position.x <= bottomLeft.x {
        //println("BottomLeftX:\(zombie.position.x, zombie.position.y)")
        zombie.position.x = bottomLeft.x
         velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            //println("BottomLeftY:\(zombie.position.x, zombie.position.y)")
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if  zombie.position.x >= topRight.x {
            //println("TopRightX:\(zombie.position.x, zombie.position.y)")
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y >= topRight.y {
        //println("TopRightY:\(zombie.position.x, zombie.position.y)")
        zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
 

    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
            let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
            let foo = CGFloat(dt)
            let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(
            min: CGRectGetMinY(playableRect) + enemy.size.height/2,
            max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)

        let actionMove = SKAction.moveToX(
            -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }


    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation),
                withKey: "animation")
        }
    }

    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func spawnCat() {
        //1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                             max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                             max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        //2
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        //cat.removeFromParent()
        runAction(SKAction.playSoundFileNamed("hitCat.wav",
            waitForCompletion: false))
        cat.name = "train"
        cat.setScale(1)
        cat.zRotation = 0
        cat.removeAllActions()
        cat.runAction(SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2))

        
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        //enemy.removeFromParent()
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        print("before:", "\(invincible)")
        //invincible = false
        let setHidden = SKAction.runBlock() {
            self.zombie.hidden = false
            self.invincible = false
        }
        
        runAction(SKAction.playSoundFileNamed("hitCatLady.wav",
            waitForCompletion: false))
        zombie.runAction(SKAction.sequence([blinkAction, setHidden]))
        print("after:", "\(invincible)")
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
        }
    }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        
        if invincible == false {

            enumerateChildNodesWithName("enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(
                    CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                        hitEnemies.append(enemy)

            }
        }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }
    }
    override func didEvaluateActions() {
        checkCollisions()
    }

    func moveTrain() {
        var targetPosition = zombie.position

        
        enumerateChildNodesWithName("train") { node, stop in
            if !node.hasActions() {
                print("train")
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSecond
                let amountToMove = amountToMovePerSec *  CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
    }

}


