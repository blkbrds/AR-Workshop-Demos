# AR-Workshop-Demos
Các demo của ARKit cho buổi technical workshop.

Mội dung:

* [00 - Setup](https://github.com/blkbrds/AR-Workshop-Demos#part-00-setup)

* [01 - Introduction](https://github.com/blkbrds/AR-Workshop-Demos#part-01-introduction)

  

---

###  Part 00: Setup

```swift
import ARKit
```

Tạo project và import ARKit

Tại file `*.xib` của ViewController, kéo thả *ARSCNView* vào view và kéo outlet cho nó.

Tại file `*.swift` của ViewController, cài đặt 2 functions:

```swift
@IBOutlet weak var sceneView: ARSCNView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
```

---



### Part 01: Introduction

* Hiển thị text đơn giản trên ARKit

Tạo một node text đơn giản

```swift
func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.cyan
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        return textNode
    }
```

Thêm vào màn hình ARKit

```swift
let textNode = self.createTextNode(string: "Hello ARkit")
        textNode.position = SCNVector3(-0.1, 0, -0.3)
        sceneView.scene.rootNode.addChildNode(textNode)
```

* Hiển thị 1 box đơn giản

```swift
class func simpleBox() -> SCNNode {
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        
        return boxNode
    }
```

* Hiển thị Video trong máy bằng ARKit

```swift
 func addVideoNode() {
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        let videoNode = SKVideoNode(fileNamed: "vr_and_ar_tinhte.mp4")
        videoNode.play()
        
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        skScene.addChild(videoNode)
        
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size
        
        let tvPlane = SCNPlane(width: 1.0, height: 0.75)
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true
        
        let tvPlaneNode = SCNNode(geometry: tvPlane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        tvPlaneNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        tvPlaneNode.eulerAngles = SCNVector3(Double.pi,0,0)
        
        tvPlaneNode.name = "Step3"
        self.sceneView.scene.rootNode.addChildNode(tvPlaneNode)
    }
```





