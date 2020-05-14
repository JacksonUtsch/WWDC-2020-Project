import PlaygroundSupport
import SwiftUI
import SpriteKit

let defaults = UserDefaults.standard

let key = "highscore"
var highscore: Int = {
    let value = defaults.value(forKey: key) as? String // Any?
    guard value != nil else {
        return 0
    }
    return Int(value!)!
}()

struct LoaderView: View {
    
    var key: [Int: Int] = [:]
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing:0) {
                
                HStack(alignment: .top) {

                Rectangle()
                    .frame(width: 30, height: 0, alignment: .leading)
                    .foregroundColor(.clear)

                Image(uiImage: UIImage(named: "xtap.png")!)
                    .resizable()
                    .frame(width: 75, height: 75, alignment: .leading)
                    .padding(10)
                
                    VStack {
                        Rectangle()
                            .frame(width: 5, height: 70, alignment: .top)
                            .foregroundColor(.clear)
                        Text("tap")
                            .font(.largeTitle)
                            .font(.custom("Avenir Next", size: 50))
                            .fontWeight(.light)
                            .foregroundColor(Color(Game.Color.darkBlue))
                        Text("highscore: \(highscore)")

                    }.frame(width: 300, height: 0, alignment: .leading)
                                        
                    Spacer()

                }.padding(10)
                
                Divider()
                Spacer()

                ForEach((0...Game.objectCount() - 1), id: \.self) { i in
                    ZStack {
                        Image(uiImage: Game.renderImage(from: Game.objects()[i])!)
                            .resizable()
                            .frame(width: 90, height: 90, alignment: .center)
                        Text("\(i)")//String(self.key[i] + 1))
                            .foregroundColor(Color(Game.Color.white))
                            .font(.title)
                    }
                }
                
                Spacer()

                NavigationLink(destination: gameStack.navigationBarTitle("").navigationBarHidden(true)) {
                    Text("Start")
                        .foregroundColor(Color(Game.Color.green))
                        .font(.largeTitle)
                        .padding(15)
                }.simultaneousGesture(TapGesture().onEnded({
                    gameStack.reset()
                }))
                
            }
            .background(Color(Game.Color.white))
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

var gameStack = GameStack()

struct GameStack: View {

    @ObservedObject var observedObject = ObservableVariables()

    var gameView = GameView() // declaration required outside body scope to not reset with SwiftUI.
    var gameBoard = GameBoard()
    
    var body: some View {
        NavigationView {
            ZStack {
                gameView
                
                VStack {
                    
                    HStack {
                        
                        VStack {
                            Text(String(observedObject.objectCount))
                                .foregroundColor(Color(Game.Color.green))
                                .bold()
                                .fontWeight(.heavy)
                                .font(.title)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(String(observedObject.lives))
                                .foregroundColor(Color(Game.Color.green))
                                .bold()
                                .fontWeight(.heavy)
                                .font(.title)
                        }
                    }
                    
                    Spacer()
                }.padding()
                
//                if observedObject.showingBoard {
//                    gameBoard.opacity(1)
//                } else {
//                    gameBoard.opacity(0)
//                }
                if observedObject.showingBoard {
                    HStack {
                        gameBoard
                    }//.navigationBarTitle("").navigationBarHidden(true)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
    func reset() {
        observedObject.showingBoard = false
        observedObject.objectCount = 0
        observedObject.lives = "|||"
        gameView.scene.removeAllChildren()
        gameView.scene.startSpawns()
    }
}

// accounts for game variables
class ObservableVariables: ObservableObject {
    @Published var objectCount: Int
    @Published var lives: String
    @Published var objectsKey: [Int]
    @Published var showingBoard: Bool
    
    init() {
        objectCount = 0
        lives = "|||"
        objectsKey = []
        showingBoard = false
    }
}

// View -> UIViewRepresentable(SKView) -> SKScene -> SKShapeNode
struct GameView: UIViewRepresentable {
    
    let scene: GameScene
    
    var spawning = false
    
    init() {
        scene = GameScene(size: .zero)
        scene.scaleMode = .resizeFill // assures that the scene is rescaled to fit the view
    }
    
    func makeUIView(context: Context) -> SKView {
        // SwiftUI handles sizing the SKView
        return SKView(frame: .zero)
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(scene)
        view.showsNodeCount = true
        view.showsFPS = true
    }
}

class GameScene: SKScene, ObservableObject {
    
    var spawnTimer: Timer?
    var active: Bool = false
        
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = Game.Color.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startSpawns() {
        print("startSpawns")
        active = true
        spawnTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.spawnTimed), userInfo: nil, repeats: true)
    }
    
    @objc func spawnTimed() {
        if self.frame.width > 0 {
            let radius: CGFloat = 50
            let node = GameObject(active: true, objectIndex: Int.random(in: 0...(Game.objectCount() - 1)))
            print(self.frame)
            let posx = CGFloat.random(in: 0...((self.frame.width) - radius))
            let posy = CGFloat.random(in: 0...((self.frame.height) - radius))
            node.position = CGPoint(x: posx, y: posy)
            addChild(node)
        }
    }
    
    func gameOver() {
        active = false
        spawnTimer?.invalidate()
        spawnTimer = nil
        if gameStack.observedObject.objectCount > highscore {
            defaults.set("\(gameStack.observedObject.objectCount)", forKey: key)
            highscore = gameStack.observedObject.objectCount
        }
        gameStack.observedObject.showingBoard = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if game is not active ignore scene touches
        guard active else {
            return
        }
        let touch = touches.first
        let touchPosition = touch!.location(in: self)
        print("touch: \(touchPosition)")

        var touched = false
        for case let object as GameObject in nodes(at: touchPosition) {
            touched = true
            object.touchesRemain -= 1
            if object.touchesRemain <= 0 {
                object.destroy()
                gameStack.observedObject.objectCount += 1
            }
        }
        
        if touched == false {
            if gameStack.observedObject.lives.count >= 1 {
                gameStack.observedObject.lives.removeFirst()
                if gameStack.observedObject.lives == "" {
                    gameOver()
                }
            }
        }
    }
}

struct GameBoard : View {
        
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 5)
            
            VStack {
                
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(Color(Game.Color.white))
                    .padding(10)
                
                Text("Score: \(gameStack.observedObject.objectCount)")
                    .foregroundColor(Color(Game.Color.white))
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: loader.navigationBarTitle("").navigationBarHidden(true)) {
                        Text("Retry")
                            .padding(10)
                            .foregroundColor(Color(Game.Color.white))
                    }.simultaneousGesture(TapGesture().onEnded({

                    }))
                }
                
                RoundedRectangle(cornerRadius: 5).foregroundColor(Color(Game.Color.blue))
            }
            
        }
        .fixedSize()
        .foregroundColor(Color(Game.Color.darkBlue))
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

let loader = LoaderView()
PlaygroundPage.current.setLiveView(loader)
