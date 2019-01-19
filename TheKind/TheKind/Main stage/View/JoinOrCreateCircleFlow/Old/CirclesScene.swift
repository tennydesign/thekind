//
//  CirclesScene.swift
//  TheKind
//
//  Created by Tenny on 1/16/19.
//  Copyright © 2019 tenny. All rights reserved.
//
// #0 Select circles that are close to the user in the radius of... (user FIRESTORE queries, must be optmized).
// SELECT top (20) id, ( 6371 * acos( cos( radians(13.0610) ) * cos( radians( lat ) ) * cos( radians( lng ) - radians(80.2404) ) + sin( radians(13.0610) ) * sin( radians( lat ) ) ) ) AS distance
//FROM markers  ORDER BY distance;
//Here instead of 13.0610 you have to pass your self location latitude, and 80.2404 is longitude
// #return self.locationManager.location!.distance(from: crumbLocation)


// #1 Create circles with dynamic size, text and link reference.

// #2 give it a physicsbody and a collision mask
// #3 create a boundary with a collision mask
// #4 activate gravity and let them bump

import UIKit
import SpriteKit
class CirclesScene: SKScene, SKPhysicsContactDelegate {
    override func sceneDidLoad() {
        createCircle(qty: 20)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody!.isDynamic = true
        self.physicsBody!.pinned = true
        self.physicsBody!.categoryBitMask = 4294967295
        self.physicsBody!.restitution = 1
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0.03)
      }

    override func didMove(to view: SKView) {
        //self.createCircle()
    }
    
    
    func createCircle(qty: Int) {
        let radius:CGFloat = 70
        print(self.size.height,self.size.width)
        let ySpace = self.size.height
        let xSpace = self.size.width
        let screenArea = ySpace*xSpace
        
        let circleSquaredArea = ((radius*2)*(radius*2))
        let qtdCircles = Int(floor(screenArea/circleSquaredArea)) - 2
        print(qtdCircles)
        
        
        
        
        for _ in 1...qtdCircles {
            let positionx = random(min: (self.frame.minX+30) + radius*2 , max: (self.frame.maxX-30) - radius*2)
            let positiony = random(min: (self.frame.minY+30) + radius*2, max: (self.frame.maxY-30) - radius*2)
            
            print(isOnScreen(x: positionx, y: positiony))
           // if isOnScreen(x: positionx, y: positiony) {

                let circle = SKShapeNode(circleOfRadius: radius)
                circle.position = CGPoint(x: positionx, y: positiony)
                
                circle.strokeColor = UIColor(r: 176, g: 38, b: 65)
                circle.fillColor = UIColor.clear
                circle.lineWidth = 3
                let label = SKLabelNode(text: "Testing Label")
                label.fontName = "Acrylic Hand Sans"
                label.fontColor = UIColor(r: 237, g: 237, b: 237)
                
                label.horizontalAlignmentMode = .center
                label.fontSize = radius/6
                label.position = CGPoint(x: label.position.x, y: label.position.y - label.frame.height/2)
                
                let circleCategory: UInt32  = 0x1 << 0
                
                circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
                circle.physicsBody?.affectedByGravity = true
                circle.physicsBody?.allowsRotation = false
                circle.physicsBody?.categoryBitMask = circleCategory
                circle.physicsBody?.collisionBitMask = 4294967295 | circleCategory
                circle.addChild(label)
                self.addChild(circle)
                //}

            }
  
        
    }
    
    func isOnScreen(x: CGFloat, y: CGFloat)->Bool {
        var xCoord = x
        if x<0 {xCoord -= 160}
        if x>0 {xCoord += 160}
        print (x,self.frame.minY)
        if xCoord < self.frame.minX || xCoord > self.frame.maxX {
            return false
        } else {
            return true
        }
    }

}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}



extension CGRect {
    func randomPoint() -> CGPoint {
        let origin = self.origin
        return CGPoint(x:CGFloat(arc4random_uniform(UInt32(self.width))) + origin.x,
                       y:CGFloat(arc4random_uniform(UInt32(self.height))) + origin.y)
    }
}
