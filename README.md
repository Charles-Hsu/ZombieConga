ZombieConga
===========
A practice follows the guide of Ray Wenderlich

using Swift + SpriteKit
http://www.raywenderlich.com/store/ios-games-by-tutorials

Updated 
----------------

2014/12/04 

增加 boundsCheckZombie() 讓 Rombie 只能在 scene 內移動, 撞到牆壁會反彈.

由於 1024x768 的比例 3:2 = 3/2 = 1.33 僅符合 iPad, 
但 iPhone 的規格卻是 16:9 = 16/9 = 1.77. == maxAspectRatio
iPad Retina 為 2048x1536. 也就是 1024x768 的兩倍. 
實際運作時 Zombie 會跑出 iPhone 的畫面外, 
新增 playableRect 來解決這個問題.

考慮增加一個 Zombie 會依照前進方向而轉動的功能.
目前限制 Zombie 只能在 16:9 的空間裡活動, 以後要改成可以在 visable area 內活動

因為已經知道方向了, 由 velocity 變數可知單位向量 = Vector / 斜邊長
已知 x 和 y, 透過三角函數可以得知角度. tangle角 y/x.
也就是說 tan(angle) = y / x.
也就是說 angle = arc-tangle ( y / x).
換成 swift 的函數 --> angle = arctan(y/x)

```swift
func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) { 
    sprite.zRotation = CGFloat(
        atan2(Double(direction.y), Double(direction.x))) 
}
```



