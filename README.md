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
原本採用 touch.count == 2 的方式來 stop Rombie, 
後來看 Tutorial 有更好的方式, 也就是先記錄上一次 touch 的地方, 
然後在 update() 裡計算 Zombie 預計前往的位置, 比較兩者的大小. 
不過這樣做比較複雜, 但原本的做法沒有保留方向, 使得每次暫停 Stop 時, 
都會面向右邊. 可能需要再保留方向, 好處是只要在螢幕任意地方連敲兩下, 就可以暫停.

###
關於暫停的做法, 還是沒解. 看了 pdf, 寫完 code 的之後, 發現不是暫停, 而是會停在 lastTouchLocation 的地方, 和我想像的一二三木頭人是不一樣的. 暫時擺著, 慢慢再想. 不然只好整合原本的做法, 但記得要記錄方向, 讓木頭人維持方向. 但定住不動就是了!

增加了一段 Helper 的 Swift 檔, 使程式碼看起來更簡潔

```swift
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

// 還有除法

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint) {
    left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (inout point: CGPoint, scalar: CGFloat) {
    point = point * scalar
}

// 還有除法

extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }

    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
}
```

Info
====
基本上, 程式的內容是依照[iOS Games by Tutorials Second Edition](http://www.raywenderlich.com/store/ios-games-by-tutorials)邊學邊記錄邊改的. 54$美金的教材, 換成台幣約1,700元, 主要還是要花上自己的時間跟努力, 還要不斷練習, 不要依照範本, 自己寫一個後, 才能深化後熟能生巧.

```
/*
 * Copyright (c) 2013-2014 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 */
 ```

 很好的教材, 建議有興趣者, 不妨花時間去購買.



