//
//  GameObject.swift
//  BackToIt
//
//  Created by admin on 4/20/20.
//  Copyright © 2020 admin. All rights reserved.
//

import SpriteKit

public class GameObject: SKShapeNode {
    private let radius: CGFloat = 50
    private var objectIndex: Int
    public var touchesRemain: Int
    
    private let initialTime:CGFloat = 3
    private var time: CGFloat = 3
    private var timer: Timer?
    private var decayNode: SKShapeNode
    
    public init(active: Bool, objectIndex: Int) {
        self.objectIndex = objectIndex
        self.touchesRemain = objectIndex
        
//        if active == true {
//            var value = 0 + 1
//            for i in gameStack.observedObject.objectsKey.enumerated() {
//                if i.offset == objectIndex {
//                    value = i.element + 1
//                }
//            }
//            self.touchesRemain = value
//        }
        
        decayNode = SKShapeNode(circleOfRadius: radius)
        decayNode.lineWidth = 0
        
        super.init()
        path = UIBezierPath(roundedRect: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), cornerRadius: radius).cgPath
        position = CGPoint(x: radius, y: radius)
        fillColor = .clear
        strokeColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:0.50)
        lineWidth = 5

        decayNode.fillColor = Game.colors[objectIndex]

        addChild(decayNode)
        
        if active == true {
            timer = Timer.scheduledTimer(timeInterval: (1/60), target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    @objc public func countDown() {
        time -= CGFloat(timer!.timeInterval)
        
        if time <= 0 {
            destroy()
            return
        }
        
        decayNode.setScale(time / initialTime)
                
        decayNode.removeFromParent()
        self.addChild(decayNode)
    }
    
    public func destroy() {
        timer?.invalidate()
        self.removeFromParent()
    }
}
