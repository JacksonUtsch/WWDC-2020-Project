//import SwiftUI
//import SpriteKit
//
////public var gameStack = GameStack()
//
//public struct GameStack: View {
//
//    @ObservedObject public var observedObject = ObservableVariables()
//
//    public var gameView = GameView() // declaration required outside body scope to not reset with SwiftUI.
//        
//    public var body: some View {
//        NavigationView {
//            ZStack {
//                gameView
//                
//                VStack {
//                    
//                    HStack {
//                        
//                        VStack {
//                            Text("placeholder")//String(observedObject.objectCount))
//                                .foregroundColor(Color(Game.Color.green))
//                                .bold()
//                                .fontWeight(.heavy)
//                                .font(.title)
//                        }
//                        
//                        Spacer()
//                        
//                        VStack {
//                            Text("placeholder")//String(observedObject.lives))
//                                .foregroundColor(Color(Game.Color.green))
//                                .bold()
//                                .fontWeight(.heavy)
//                                .font(.title)
//                        }
//                    }
//                    
//                    Spacer()
//                }.padding()
//                
////                if observedObject.showingBoard {
////                    GameBoard()
////                }
//            }
//            .navigationBarTitle("")
//            .navigationBarHidden(true)
//        }
//    }
//    
//    public func reset() {
////        observedObject.showingBoard = false
////        observedObject.objectCount = 0
////        observedObject.lives = "|||"
//        gameView.scene.removeAllChildren()
////        gameView.scene.startSpawns()
//    }
//}
//
//// accounts for game variables
//public class ObservableVariables: ObservableObject {
//    @Published public var objectCount: Int
//    @Published public var lives: String
//    @Published public var objectsKey: [Int]
//    @Published public var showingBoard: Bool
//    
//    public init() {
//        objectCount = 0
//        lives = "|||"
//        objectsKey = []
//        showingBoard = false
//    }
//}
//
//// View -> UIViewRepresentable(SKView) -> SKScene -> SKShapeNode
//public struct GameView: UIViewRepresentable {
//    
//    public let scene: SKScene
//    
//    public init() {
//        scene = SKScene(size: .zero)
//        scene.scaleMode = .resizeFill // assures that the scene is rescaled to fit the view
//    }
//    
//    public func makeUIView(context: Context) -> SKView {
//        // SwiftUI handles sizing the SKView
//        return SKView(frame: .zero)
//    }
//    
//    public func updateUIView(_ view: SKView, context: Context) {
//        view.presentScene(scene)
//        view.showsNodeCount = true
//        view.showsFPS = true
//    }
//}
//
//public class GameScene: SKScene, ObservableObject {
//    
//    public var spawnTimer: Timer?
//    public var active: Bool = false
//        
//    public override init(size: CGSize) {
//        super.init(size: size)
//        backgroundColor = Game.Color.white
//    }
//    
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public func startSpawns() {
//        active = true
//        spawnTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.spawnTimed), userInfo: nil, repeats: true)
//    }
//    
//    @objc public func spawnTimed() {
//        let radius: CGFloat = 50
//        let node = GameObject(active: true, objectIndex: Int.random(in: 0...(Game.objectCount() - 1)))
//        let posx = CGFloat.random(in: 0...((self.frame.width) - radius))
//        let posy = CGFloat.random(in: 0...((self.frame.height) - radius))
//        node.position = CGPoint(x: posx, y: posy)
//        addChild(node)
//    }
//    
//    public func gameOver() {
//        active = false
//        spawnTimer?.invalidate()
//        spawnTimer = nil
//        // update highscore?
////        gameStack.observedObject.showingBoard = true
//    }
//    
//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        // if game is not active ignore scene touches
//        guard active else {
//            return
//        }
//        let touch = touches.first
//        let touchPosition = touch!.location(in: self)
//        
//        var touched = false
//        for case let object as GameObject in nodes(at: touchPosition) {
//            touched = true
//            object.touchesRemain -= 1
//            if object.touchesRemain <= 0 {
//                object.destroy()
////                gameStack.observedObject.objectCount += 1
//            }
//        }
//        
//        if touched == false {
////            if gameStack.observedObject.lives.count >= 1 {
////                gameStack.observedObject.lives.removeFirst()
////                if gameStack.observedObject.lives == "" {
////                    gameOver()
////                }
////            }
//        }
//    }
//}
