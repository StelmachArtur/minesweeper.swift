import SpriteKit

class Tile {
    var x_pos_: Int
    var y_pos_: Int
    var neighboring_bombs_: Int
    var is_clicked_: Bool
    var is_flagged_: Bool
    var is_bomb_: Bool
    var sprite_: SKSpriteNode
  
    
    init(posx: Int, posy: Int) {
        self.x_pos_ = posx
        self.y_pos_ = posy
        self.neighboring_bombs_ = 0
        self.is_bomb_ = false
        self.is_clicked_ = false
        self.is_flagged_ = false
        self.sprite_ = SKSpriteNode()
        print("Tile generated at ", posx, " ", posy)
    }
}
