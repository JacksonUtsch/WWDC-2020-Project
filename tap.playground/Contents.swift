import PlaygroundSupport
import SwiftUI
import SpriteKit

/// to fix playground bug
var ranOnce = false
let coordinator = Coordinator()

let defaults = UserDefaults.standard
let highscoreKey = "highscore"
var highscore: Int = {
    let value = defaults.value(forKey: highscoreKey) as? String
    guard value != nil else {
        return 0
    }
    return Int(value!)!
}()

/// menu of app, sets up game key
struct LoaderView: View {
    
    var key: [Int: Int] = [:]
        
    init() {
        print(
            """
            Thanks for checking out this playground
            I hope the interactive game is at least a little fun and challenging

            Try to remember to number associated with each colored circle
            It'll help you after you press start

            """)
    }
    
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
                            .foregroundColor(Color(UIColor(red:0.48, green:0.57, blue:0.61, alpha:1.00)))

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
                        Text(String(coordinator.objectsKey[i] + 1))
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
                    gameStack.gameView.scene.startSpawns()
                }))
                
            }
            .background(Color(Game.Color.white))
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

let gameStack = GameStack()

/// layered game stack
struct GameStack: View {

    @ObservedObject var observedObject: Coordinator = coordinator
    
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
                
                if observedObject.showingBoard {
                    GameBoard()
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
    func reset() {
        observedObject.reset()
        for case let child as GameObject in gameView.scene.children {
            child.removeFromParent()
            child.destroy()
        }
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
        
        // uncomment to show scene details
//        view.showsNodeCount = true
//        view.showsFPS = true
    }
}

class GameScene: SKScene, ObservableObject, GameObjectDelegate {
    
    @ObservedObject var observedObject: Coordinator = coordinator

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
        print("starting spawns")
        active = true
        spawnTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.spawnTimed), userInfo: nil, repeats: true)
    }
    
    @objc func spawnTimed() {
        if self.frame.width > 0 {
            let radius: CGFloat = 50
            let node = GameObject(active: true, objectIndex: Int.random(in: 0...(Game.objectCount() - 1)), objRef: coordinator)
            node.delegate = self
            let posx = CGFloat.random(in: 0...((self.frame.width) - radius))
            let posy = CGFloat.random(in: 0...((self.frame.height) - radius))
            node.position = CGPoint(x: posx, y: posy)
            
            if active == true {
                var value = 0 + 1
                for i in observedObject.objectsKey.enumerated() {
                    if i.offset == node.objectIndex {
                        value = i.element + 1
                    }
                }
                node.touchesRemain = value
            }

            addChild(node)
        }
    }
    
    func gameOver() {
        print("you scored \(coordinator.objectCount)")
        print("game over\n")
        active = false
        ranOnce = true
        spawnTimer?.invalidate()
        spawnTimer = nil
        if observedObject.objectCount > highscore {
            defaults.set("\(observedObject.objectCount)", forKey: highscoreKey)
            highscore = observedObject.objectCount
        }
        gameStack.observedObject.showingBoard = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if game is not active ignore scene touches
        guard active else {
            return
        }
        let touch = touches.first
        var touchPosition = touch!.location(in: self)
        
        // playgrounds bug temp fix, works w/o in .xcodeproj
        if ranOnce {
            touchPosition.y += 170
        }

        var touched = false
        for case let object as GameObject in nodes(at: touchPosition) {
            touched = true
            object.touchesRemain -= 1
            if object.touchesRemain <= 0 {
                object.destroy()
                observedObject.objectCount += 1
            }
        }
        
        if touched == false {
            if observedObject.lives.count >= 1 {
                observedObject.lives.removeFirst()
                if observedObject.lives == "" {
                    gameOver()
                }
            }
        }
    }
}

/// game over menu
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
                    NavigationLink(destination: loaderView.navigationBarTitle("").navigationBarHidden(true)) {
                        Text("Retry")
                            .padding(10)
                            .foregroundColor(Color(Game.Color.white))
                    }.simultaneousGesture(TapGesture().onEnded({
                        gameStack.observedObject.newKey()
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

let loaderView = LoaderView()
PlaygroundPage.current.setLiveView(loaderView)
