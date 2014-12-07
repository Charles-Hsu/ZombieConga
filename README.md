ZombieConga
===========
A practice follows the guide written by Ray Wenderlich's Team

using Swift + SpriteKit
http://www.raywenderlich.com/store/ios-games-by-tutorials

Updated 
----------------
2014/12/07

加入兩個 functions 讓 Zombie 在停止時可以不要 12343212... 的扭來扭去, 利用 SKAction.actionForKey 來實作, 由於 key 是 string, 可能會打錯, 所以定義一個 constant 在 class 的 property 裡頭, 避免不小心打錯 string

```swift

let zombieAnimationKey = "animation"

func startZombieAnimation() {}
func stopZombieAnimation() {}

```

有了主角 Zombie, 有 Crazy Cat Lady, 接下來就要再加入 Cat. 出現的方式用 Pop in, 先設 scale 為 0, 然後一會兒後變成 1, 停留 10 秒鐘, 變為 0, 再消失掉. 完成後, 應該是要加入碰撞的功能以及聲音了, 還有背景應該要可以移動, 所以背景的頭尾要注意能銜接, 串得起來. Zombie 有生命點數, 被 Crazy Cat Lady 吃掉, 也就是撞到幾次後, 就應該要 lost the game. 或許可以再增加過關的功能, 也就是 Cat Lady 越來越快 ... 

SpriteKit 有兩種 Collision 的 detect 方式, 1) Intermediate Physics 2) bounding-box, 用 enumerateChildNodesWithName(usingBlock:) 搭配 Sprite 的 frame 屬性.

```swift
override func didEvaluateActions() {
    checkCollision()
}
```

測試了一下 update() 和 didEvaluateActions() 的差別, 發現在 simulator 上差別不大, 甚至 update() 還快了一點點 XD

接下來要加入聲音, 一個沒有聲音的 game 怪怪的, 雖然有時很吵, 但可以調小聲一點點. 聲音可以以屬性的方式先在 property 裡載入, 不需要在 func 中每次載入. 另外就是要增加一個無效的功能, 也就是被敵人打到時, 可以維持一段時間算是金剛不壞一閃一閃的 invicible status.

2014/12/06

增加了 Crazy Cat Lady, 但為何撞到邊會彈回來, 而 Zombie 卻不會? 如果把 update() 裡頭的 boundsCheckRombie() mark 掉的話. 似乎是 SKAction 自己和其他的 Sprite 的作用. 慢慢再看!

再把 Zombie 加工, 用 Textures 的方式, 讓 Zombie 移動時有 1234321234... 的圖片動態的循環.

```swift
    var textures:[SKTexture] = []
    for i in 1...4 {
        textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    textures.append(textures[2])
    textures.append(textures[1])
```

2014/12/05

接下來要弄一個慢慢轉向的功能, 和我想的一樣. 不然, 現在直接轉身過去, 有點突兀. 附帶一提, swift 可以用中文名稱當變數. 當然也可以用 π 來當變數, 在程式碼裏頭寫這一小段. π 可以用 Option + p. 而 degree 可以用 Option + Shift + 8 來產生 ° 度的符號. π 可以用在程式裡頭, 不過 ° 度, 可能用在註解裡頭就好.

```swift
let π = CGFloat(M_PI) // 360°
```

由於 Swift 裡頭關於角度採用的是 Radian 為計算單位, 一個 π 等於 180°, 參考這裡 [Degree/Radian Circle](http://math.rice.edu/~pcmi/sphere/drg_txt.html). 我們已經知道目前的方向 degree1, 要轉向到 degree2, 先看目前的方向, 依照要轉的方向, 計算最短的轉向, 是向右轉90°, 而不是向左轉270°. 嗯！看來要先研究一下搞懂數學計算, 完整復習一下 [Vector](http://http://www.mathsisfun.com/algebra/vectors.html) 的概念.

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

關於暫停的做法, 還是沒解. 看了 pdf, 寫完 code 的之後, 發現不是暫停, 而是會停在 lastTouchLocation 的地方, 和我想像的一二三木頭人是不一樣的. 只好看答案, 結果真的是停在 lastTouch 之處. 先暫時擺著, 慢慢再想. 不然只好整合原本的做法, 但記得要記錄方向, 讓木頭人維持方向. 但定住不動就是了!

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
基本上, 程式的內容是依照[iOS Games by Tutorials Second Edition](http://www.raywenderlich.com/store/ios-games-by-tutorials)邊學邊記錄邊改的. 54$美金的教材, 換成台幣約1,700元, 主要還是要花上自己的時間跟努力, 還要不斷練習, 不要依照範本, 自己寫一個後, 才能深化後熟能生巧. 就像鋼琴譜一樣, 一首曲子不過幾張紙, but, 幾分鐘的曲子, 要花多少時間才能熟練?! 大概十年吧!

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



