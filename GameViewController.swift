import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // Variables
    var currentGame: GameScene?
    weak var setupVC: SetupViewController?
    
    // Outlets
    @IBOutlet weak var playOnTimeSwitcj: UISwitch!
    @IBOutlet weak var flaggingSwitch: UISwitch!
    @IBOutlet weak var playingPressedOutlet: UISwitch!
    @IBOutlet weak var bombCountTextField: UITextField!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var sizeTextField: UITextField!
    
    // Actions
    @IBAction func restartGame(_ sender: Any) {
        currentGame?.board.RestartGame()
    }
    @IBAction func playingPressed(_ sender: Any) {
        if playingPressedOutlet.isOn == true {
            currentGame?.board.playWithTime(self)
            currentGame?.board.is_timed_play_ = true
        } else {
            currentGame?.timer.invalidate()
            currentGame?.board.is_timed_play_ = false
        }
    }
    @IBAction func flaggingAction(_ sender: Any) {
        currentGame?.board.flagging = flaggingSwitch.isOn
    }
    // objc methods
    @objc func longPressFunc () {
        let recognizer = view.gestureRecognizers?.last
        if (recognizer?.state == .began) {
            //print("Begin")
            self.becomeFirstResponder()
            print("recogniwe loc ",recognizer?.location(in: self.view))
            let loc = recognizer?.location(in: currentGame?.view)
            print("currentGame midX, midY",currentGame?.size.width, currentGame?.board.node.frame.midY)
            print("Position of board",currentGame?.board.node.position)
            
            if let globalView = currentGame?.view?.superview?.convert((currentGame?.frame.origin)!, to: nil) {
                print("Global trick (current game origin) ",globalView)
                if let lo = loc {
                currentGame?.board.FlaggingHandler(posx: lo.x+globalView.x, posy: lo.y-globalView.y)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = UILongPressGestureRecognizer()
        recognizer.addTarget(self, action: #selector(longPressFunc))
        self.view.addGestureRecognizer(recognizer)
        let scene = GameScene.newGameScene()
        
        let skView = self.view as! SKView
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        
        currentGame = scene as? GameScene
        currentGame?.viewController = self
        currentGame?.board.viewController = self
              
        if setupVC?.setupNameField.text != nil {
            // TODO add player
        }
        if setupVC?.setupBombsField.text != nil {
           bombCountTextField?.text = setupVC?.setupBombsField.text
        }
        if setupVC?.setupGridSizeField.text != nil {
           sizeTextField?.text = setupVC?.setupGridSizeField.text
        }
        currentGame?.board.RestartGame()
    }

    override var shouldAutorotate: Bool {
        return true
    }
   
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

