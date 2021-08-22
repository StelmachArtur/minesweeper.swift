//
//  SetupViewController.swift
//  Minesweeper iOS
//
//  Created by Artur Stelmach on 14/01/2021.
//  Copyright © 2021 NSScreencast. All rights reserved.
//


import SpriteKit

//TODO handle winning when player is not flagging
//TODO na 5:
// timed gameplay
// animations
// leaderboard

class GameBoard {
    let node: SKShapeNode
    var size: Int
    weak var viewController: GameViewController?
    var flagging: Bool
		
    private var tileSize: CGSize {
        CGSize(
            width: node.frame.width / CGFloat(size),
            height: node.frame.height / CGFloat(size)
        )
    }
    var elapsed_time: Int
    let plate_texture_: SKTexture
    let bomb_texture_: SKTexture
    let flag_texture_: SKTexture
    let plate_clicked_texture_: SKTexture
    let plate1_clicked_texture_: SKTexture
    let plate2_clicked_texture_: SKTexture
    let plate3_clicked_texture_: SKTexture
    let plate4_clicked_texture_: SKTexture
    let plate5_clicked_texture_: SKTexture	
    let plate6_clicked_texture_: SKTexture
    let plate7_clicked_texture_: SKTexture
    let plate8_clicked_texture_: SKTexture
    let lost_bomb_texture_: SKTexture
    let wrong_flag_texture_: SKTexture

    var grid_: [[Tile]]
    var first_click_:Bool
    var bombs_left_: Int
    var bombs_: Int
    var playing_: Bool
    var is_timed_play_: Bool
    let rotateRate = (SKAction.rotate(byAngle: CGFloat(4*M_PI_2), duration: 0.5))
    
   
    init(size: Int) {
        self.size = size
        node = SKShapeNode()
        node.strokeColor = .clear
        node.position = .zero
        plate_texture_ = SKTexture(imageNamed: "not_clicked_plate")
        bomb_texture_ = SKTexture(imageNamed: "bomb")
        flag_texture_ = SKTexture(imageNamed: "flag")
        plate_clicked_texture_ = SKTexture(imageNamed: "clicked_plate")
        plate1_clicked_texture_ = SKTexture(imageNamed: "1_clicked_plate")
        plate2_clicked_texture_ = SKTexture(imageNamed: "2_clicked_plate")
        plate3_clicked_texture_ = SKTexture(imageNamed: "3_clicked_plate")
        plate4_clicked_texture_ = SKTexture(imageNamed: "4_clicked_plate")
        plate5_clicked_texture_ = SKTexture(imageNamed: "5_clicked_plate")
        plate6_clicked_texture_ = SKTexture(imageNamed: "6_clicked_plate")
        plate7_clicked_texture_ = SKTexture(imageNamed: "7_clicked_plate")
        plate8_clicked_texture_ = SKTexture(imageNamed: "8_clicked_plate")
        lost_bomb_texture_ = SKTexture(imageNamed: "lost_bomb")
        wrong_flag_texture_ = SKTexture(imageNamed: "wrong_flag")
        grid_ = []
        for i in 0...size-1 {
            grid_.append([])
            for j in 0...size-1 {
                let tile = Tile(posx: j, posy: i)
                grid_[i].append(tile);
                tile.sprite_.texture = plate_texture_
                node.addChild(tile.sprite_)
            }
        }
        elapsed_time = 0
        first_click_ = true
        bombs_left_ = 10
        bombs_ = 10
        playing_ = true
        flagging = false
        is_timed_play_ = false
        RestartGame()
    }
    
    func RestartGame(){
        first_click_ = true
        if (viewController?.bombCountTextField.text != nil) {
            let bombs = Int((viewController?.bombCountTextField.text)!) ?? 10
                bombs_left_ = bombs
                bombs_ = bombs
        }
        playing_ = true
        flagging = false
        viewController?.flaggingSwitch.setOn(false, animated: true)
        viewController?.playOnTimeSwitcj.setOn(false, animated: true)
        if (viewController?.sizeTextField.text != nil) {
            let sizeGrid = Int((viewController?.sizeTextField.text)!) ?? 10
            size = sizeGrid
        }
        node.removeAllChildren()
        grid_ = []
        for i in 0...size-1 {
            grid_.append([])
            for j in 0...size-1 {
                let tile = Tile(posx: j, posy: i)
                grid_[i].append(tile);
                tile.sprite_.texture = plate_texture_
                node.addChild(tile.sprite_)
            }
        }
        viewController?.currentGame?.getBoardSize()
        self.elapsed_time = 0
        viewController?.currentGame?.timer.invalidate()
        viewController?.currentGame?.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(incrementTime), userInfo: nil, repeats: true)
    }

    @objc func incrementTime() {
        elapsed_time += 1
        self.viewController?.elapsedTimeLabel.text = "Time: \(elapsed_time)"
    }
    
    func getBoardSize(to boardSize: CGSize) {
        node.path = CGPath(rect: CGRect(x: -boardSize.width/2, y: -boardSize.height/2, width: boardSize.width, height: boardSize.height), transform: nil)
	
        print(tileSize.width,tileSize.height)
        for row in 0..<grid_.count {
            for tile in 0..<grid_[row].count {
                grid_[row][	tile].sprite_.size = tileSize
                let x = node.frame.minX + (CGFloat(tile)+0.5) * tileSize.width
                let y = node.frame.maxY - (CGFloat(row)+0.5) * tileSize.height

                grid_[row][tile].sprite_.position = CGPoint(x: x, y: y)
            }
        }
    }

    func PickBombsPositions(bomb_count: Int) {
        
        var bombs_to_place = bomb_count;
        // pick bombs positions
        if (bomb_count >= grid_[0].count*grid_.count) {
            bombs_to_place = Int(sqrt(Double(grid_[0].count*grid_.count)))
            viewController?.bombCountTextField.text = String(bombs_to_place)
        }
        var posx = 0
        var posy = 0
        while (bombs_to_place > 0) {
            posx = 	Int.random(in: 0..<grid_[0].count)
            posy =  Int.random(in: 0..<grid_.count)
            if (grid_[posy][posx].is_bomb_ || grid_[posy][posx].is_clicked_) {
                continue;
            }
            else {
                grid_[posy][posx].is_bomb_ = true
                bombs_to_place -= 1
            }
        }
    }

    func HandleWinning()
    {
        DisplayAllPlates(lost_bomb_pos_x: -1, lost_bomb_pos_y: -1)
        showWinWindow()
        viewController?.currentGame?.timer.invalidate()
    }

    func showWinWindow() {
        let score = floor((1.0/Float(elapsed_time)) * Float(bombs_) * 1000.0)
           // create the alert
           let alert = UIAlertController(title: "You win!", message: "Your score was: \(score)", preferredStyle: UIAlertController.Style.alert)

           // add an action (button)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

           // show the alert
        self.viewController?.present(alert, animated: true, completion: nil)
       }
    
    func showLoseWindow() {
          let alert = UIAlertController(title: "You lost!", message: "Try again...", preferredStyle: UIAlertController.Style.alert)

           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.viewController?.present(alert, animated: true, completion: nil)
       }
    
     func playWithTime(_ sender: Any) {
        RestartGame()
            elapsed_time = bombs_*2
            viewController?.currentGame?.timer.invalidate()
            viewController?.currentGame?.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedPlay), userInfo: nil, repeats: true)
        
    }
    @objc func timedPlay() {
        elapsed_time -= 1
        self.viewController?.elapsedTimeLabel.text = "Time: \(elapsed_time)"
        if elapsed_time == 0 {
            DisplayAllPlates(lost_bomb_pos_x: -1, lost_bomb_pos_y: -1)
            showLoseWindow()
        }
    }
    func ClickHandler(at position: CGPoint) {
        if (playing_) {
            //determine click position
            let clicked_plate_x = Int((position.x+node.frame.width/2) / (node.frame.width / CGFloat(size)))
            let clicked_plate_y = Int(abs(position.y - node.frame.height/2) / (node.frame.height / CGFloat(size)))
            
            if clicked_plate_y >= grid_.count || clicked_plate_y < 0{return}
            if clicked_plate_x >= grid_[clicked_plate_y].count || clicked_plate_x < 0 {return}
            
            print("Clicked at ",position.x, position.y,clicked_plate_x,clicked_plate_y)
            let clicked_plate = grid_[clicked_plate_y][clicked_plate_x]
            clicked_plate.sprite_.run(rotateRate)
            if (clicked_plate.is_clicked_) { return }
            if (flagging) {
                if (clicked_plate.is_flagged_) {
                    clicked_plate.sprite_.texture = plate_texture_
                    clicked_plate.is_flagged_ = false
                    if (clicked_plate.is_bomb_) {
                            bombs_left_ += 1
                        }
                        else {
                            bombs_left_ -= 1
                        }
                    }
                    else {
                        clicked_plate.sprite_.texture = flag_texture_
                        clicked_plate.is_flagged_ = true
                        if (clicked_plate.is_bomb_) {
                            bombs_left_-=1
                        } else {
                            bombs_left_+=1
                        }
                    }
            } else {
                if (first_click_) {
                    first_click_ = false;
                    
                    clicked_plate.is_clicked_ = true
                    PickBombsPositions(bomb_count: bombs_left_)
                    CountNeighboringBombs()
                    clicked_plate.sprite_.texture = GetProperTexture(neighbors: clicked_plate.neighboring_bombs_);
                    if (clicked_plate.neighboring_bombs_ == 0) {
                        RecursiveUnhiddingPlates(posx: clicked_plate_x, posy: clicked_plate_y);
                    }
                }
                else {
                    if (clicked_plate.is_bomb_ && clicked_plate.is_flagged_ == false) {
                        playing_ = false;
                        showLoseWindow()
                        viewController?.currentGame?.timer.invalidate()
                        DisplayAllPlates(lost_bomb_pos_x: clicked_plate_x, lost_bomb_pos_y: clicked_plate_y);
                    }
                    else if (clicked_plate.is_flagged_ == false){
                        clicked_plate.is_clicked_ = true
                        clicked_plate.sprite_.texture = GetProperTexture(neighbors: clicked_plate.neighboring_bombs_)
                        if (clicked_plate.neighboring_bombs_ == 0) {
                            RecursiveUnhiddingPlates(posx: clicked_plate_x, posy: clicked_plate_y);
                        }
                    }
                    }
                }
            
        }
        if (bombs_left_ == 0) {
            playing_ = false;
            HandleWinning();
        }
        
    }
    
    func FlaggingHandler(posx: CGFloat, posy: CGFloat){
        if (playing_) {
            print("Coords passed to flaggingHandler", posx, posy)
            let norm_x = posx+node.frame.width/2
            let clicked_plate_x = Int( (norm_x / (node.frame.width / CGFloat(size))))
            let norm_y = abs(CGFloat(posy) - node.frame.height/2)
            let clicked_plate_y = Int( norm_y / (node.frame.height / CGFloat(size)))
            
            if clicked_plate_y >= grid_.count || clicked_plate_y < 0{return}
            if clicked_plate_x >= grid_[clicked_plate_y].count || clicked_plate_x < 0 {return}
            
            print("Clicked at ",posx, posy,clicked_plate_x,clicked_plate_y)
            let clicked_plate = grid_[clicked_plate_y][clicked_plate_x]
            if (clicked_plate.is_clicked_) { return }
            clicked_plate.sprite_.run(rotateRate)
            if (clicked_plate.is_flagged_) {
                clicked_plate.sprite_.texture = plate_texture_
                clicked_plate.is_flagged_ = false
                if (clicked_plate.is_bomb_) {
                        bombs_left_ += 1
                        //std::cout << bombs_left_ << std::endl;
                    }
                    else {
                        bombs_left_ -= 1
                        //std::cout << bombs_left_ << std::endl;
                    }
                }
                else {
                    clicked_plate.sprite_.texture = flag_texture_
                    clicked_plate.is_flagged_ = true
                    if (clicked_plate.is_bomb_) {
                        bombs_left_-=1
                        //std::cout << bombs_left_ << std::endl;
                    }
                    else {
                        bombs_left_+=1
                       // std::cout << bombs_left_ << std::endl;
                    }
                }
        }
        if (bombs_left_ == 0) {
            playing_ = false;
            HandleWinning();
        }
        
    }
    
    func RecursiveUnhiddingPlates(posx: Int,posy: Int) {
        for i in -1...1 {
            for j in -1...1 {
                if (posy + i >= 0 && posy + i < grid_.count && posx + j >= 0 && posx + j < grid_[posy].count) {
                    if (grid_[posy + i][posx + j].neighboring_bombs_ == 0 && grid_[posy + i][posx + j].is_clicked_ == false) {
                        grid_[posy + i][posx + j].is_clicked_ = true
                        grid_[posy + i][posx + j].sprite_.run(rotateRate)
                        grid_[posy + i][posx + j].sprite_.texture = self.GetProperTexture(neighbors: grid_[posy + i][posx + j].neighboring_bombs_)
                        RecursiveUnhiddingPlates(posx: posx + j, posy: posy + i)
                    }
                    else if (grid_[posy + i][posx + j].is_clicked_ == false) {
                        grid_[posy + i][posx + j].is_clicked_ = true
                        grid_[posy + i][posx + j].sprite_.run(rotateRate)
                        grid_[posy + i][posx + j].sprite_.texture = self.GetProperTexture(neighbors: grid_[posy + i][posx + j].neighboring_bombs_);
                    }
                }
            }
        }
    }

    func GetProperTexture(neighbors: Int) -> SKTexture {
        switch (neighbors) {
        case 1: return plate1_clicked_texture_;
        case 2: return plate2_clicked_texture_;
        case 3: return plate3_clicked_texture_;
        case 4: return plate4_clicked_texture_;
        case 5: return plate5_clicked_texture_;
        case 6: return plate6_clicked_texture_;
        case 7: return plate7_clicked_texture_;
        case 8: return plate8_clicked_texture_;
        default: return plate_clicked_texture_;
        }
    }

   func CountNeighboringBombs() {
        for i in 0..<grid_.count { //foreach row
            for j in 0..<grid_[i].count { //foreach column
                if (grid_[i][j].is_bomb_) { continue }
                //count bombs in neighborhood
                var count = 0;
                for k in -1...1 {
                    for w in -1...1 {
                        if i + k >= 0 && i + k < grid_.count && j + w >= 0 && j + w < grid_[i].count {
                            grid_[i + k][j + w].is_bomb_ ? count+=1 : nil
                        }
                    }
                }
                grid_[i][j].neighboring_bombs_ = count
            }
        }
    }

    func DisplayAllPlates(lost_bomb_pos_x: Int,lost_bomb_pos_y: Int) {
        for row in grid_ {
            for plate in row {
                if (plate.is_bomb_ &&  plate.is_flagged_ == false) {
                    plate.sprite_.texture = bomb_texture_
                }
                else if (plate.is_bomb_ == false && plate.is_flagged_) {
                    plate.sprite_.texture = wrong_flag_texture_
                }
                else if (plate.is_bomb_ && plate.is_flagged_) {
                    continue;
                }
                else {
                    plate.sprite_.texture = self.GetProperTexture(neighbors: plate.neighboring_bombs_)
                }
            }
        }
        if (lost_bomb_pos_x != -1 && lost_bomb_pos_y != -1) {
            grid_[lost_bomb_pos_y][lost_bomb_pos_x].sprite_.texture = lost_bomb_texture_
        }
    }    
}
