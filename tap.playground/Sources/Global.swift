//
//  Global.swift
//  BackToIt
//
//  Created by admin on 4/18/20.
//  Copyright © 2020 admin. All rights reserved.
//

import SwiftUI
import SpriteKit

// accounts for game variables
public class Coordinator: ObservableObject {
    @Published public var objectCount: Int = 0
    @Published public var lives: String = "|||"
    @Published public var objectsKey: [Int] = Array(0...(Game.objectCount() - 1)).shuffled()
    @Published public var showingBoard: Bool = false
    
    // weird playgrounds requirement to compile
    public init() {
        
    }
    
    public func reset() {
        objectCount = 0
        lives = "|||"
        showingBoard = false
    }
    
    public func newKey() {
        print("game key reset.")
        objectsKey = Array(0...(Game.objectCount() - 1)).shuffled()
    }
}

// Game constants
public enum Game {
    
    public static let colors: [UIColor] = [Game.Color.red, Game.Color.blue, Game.Color.green, Game.Color.yellow]
            
    public enum Color {
        
        public static let red = UIColor(red:0.83, green:0.39, blue:0.44, alpha:1.00)
        public static let blue = UIColor(red:0.15, green:0.45, blue:0.71, alpha:1.00)
        public static let green = UIColor(red:0.26, green:0.61, blue:0.49, alpha:1.00)
        public static let yellow = UIColor(red:0.92, green:0.67, blue:0.35, alpha:1.00)
        
        public static let white = UIColor(red:0.85, green:0.89, blue:0.89, alpha:1.00)
        public static let darkBlue = UIColor(red:0.04, green:0.27, blue:0.30, alpha:1.00)
    }
    
}

// Game functions
extension Game {
    
    public static func objectCount() -> Int {
        return Game.colors.count
    }
    
    public static func objects() -> [GameObject] {
        var objects: [GameObject] = []
        
        for aspect in (0...Game.objectCount() - 1) {
            let object = GameObject(active: false, objectIndex: aspect, objRef: nil)
            objects.append(object)
        }
        
        return objects
    }
    
    public static func renderImage(from object: GameObject) -> UIImage? {
        let view = SKView(frame: object.frame)

        let scene = SKScene(size: CGSize(width: object.frame.width, height: object.frame.height))
        scene.addChild(object)
        view.presentScene(scene)

        guard let image = scene.view?.texture(from: object)?.cgImage() else {
            return nil
        }

        let uiImage = UIImage(cgImage: image)
        
        return uiImage
    }
}
