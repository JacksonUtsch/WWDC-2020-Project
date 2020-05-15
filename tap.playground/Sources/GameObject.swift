//
//  GameObject.swift
//  BackToIt
//
//  Created by admin on 4/20/20.
//  Copyright © 2020 admin. All rights reserved.
//

import SpriteKit

public protocol GameObjectDelegate {
    func gameOver()
}

public class GameObject: SKShapeNode {
    var object: Coordinator?
    public var delegate: GameObjectDelegate?
    
    public var touchesRemain: Int
    public var objectIndex: Int
    private var decayNode: SKShapeNode
    private var timer: Timer?
    
    private let radius: CGFloat = 50
    private let initialTime:CGFloat = 3
    private var time: CGFloat = 3
    
    public init(active: Bool, objectIndex: Int, objRef: Coordinator?) {
        self.objectIndex = objectIndex
        self.touchesRemain = objectIndex
        self.object = objRef
                
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
            if object != nil {
                if object!.lives.count >= 1 {
                    object!.lives.removeFirst()
                    if object!.lives == "" {
                        delegate!.gameOver()
                    }
                }
            }
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
