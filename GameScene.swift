import SpriteKit

class GameScene: SKScene {
    var board: GameBoard!
    weak var viewController: GameViewController?
    var timer = Timer()
    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func setUpScene() {
        board = GameBoard(size: 10)
        addChild(board.node)
        getBoardSize()
    }

    func getBoardSize() {
        guard board != nil else { return }
        let dimension = min(size.width, size.height)
        board.getBoardSize(to: CGSize(width: dimension, height: dimension))
    }

    override func didChangeSize(_ oldSize: CGSize) {
        getBoardSize()
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: board.node)
            board.ClickHandler(at: position)
        }
    }
}

