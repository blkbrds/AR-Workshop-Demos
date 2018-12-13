//
//  EnvironmentVC.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/11/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import UIKit
import ARKit

class EnvironmentVC: BaseViewController {
    
    var stepTap = 0
    
    @IBOutlet weak var sceneView: ARSCNView!
    var containerNode: SCNNode!
    var workerNode: SCNNode!
    var sheepNode: SCNNode!
    var xcodeIconNode: SCNNode!
    var spriteIconNode: SCNNode!
    var sceneIconNode: SCNNode!
    var sunNode: SCNNode!
    var iphoneNode: SCNNode!

    @IBOutlet weak var titleStepLabel: UILabel!
    
    let titles = ["Developer",
                  "Xcode",
                  "SpriteKit",
                  "SceneKit",
                  "User",
                  "Light",
                  "Device"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadScence()
    }
    
    //MARK: - Setup ARKit Screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //MARK: - Load scene
    func loadScence() {
        let gameScene = SCNScene(named: "Assets.scnassets/envScene.scn")!
        sceneView.scene = gameScene
        containerNode = gameScene.rootNode.childNode(withName: "container", recursively: true)!
        workerNode = containerNode.childNode(withName: "worker", recursively: true)!
        sheepNode = containerNode.childNode(withName: "sheep", recursively: true)!
        xcodeIconNode = containerNode.childNode(withName: "xcode", recursively: true)!
        spriteIconNode = containerNode.childNode(withName: "spritekit", recursively: true)!
        sceneIconNode = containerNode.childNode(withName: "scencekit", recursively: true)!
        sunNode = containerNode.childNode(withName: "sun", recursively: true)!
        iphoneNode = containerNode.childNode(withName: "iphone", recursively: true)!
        
        
        containerNode.position = SCNVector3(0, 0, -0.5)
        
        //add action
        let action = SCNAction.rotate(by: 360 * CGFloat((Double.pi)/180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
        let repeatAction = SCNAction.repeatForever(action)
        workerNode.runAction(repeatAction)
        sheepNode.runAction(repeatAction)
        xcodeIconNode.runAction(repeatAction)
        spriteIconNode.runAction(repeatAction)
        sceneIconNode.runAction(repeatAction)
        sunNode.runAction(repeatAction)
        iphoneNode.runAction(repeatAction)
            
        //reset
        resetSceneNodes()
        // step 0
        workerNode.position = SCNVector3(0,0, -0.5)
        containerNode.addChildNode(workerNode)
    }
    
    func resetSceneNodes() {
        stepTap = 0
        
        //remove nodes
        xcodeIconNode.removeFromParentNode()
        sheepNode.removeFromParentNode()
        xcodeIconNode.removeFromParentNode()
        spriteIconNode.removeFromParentNode()
        sceneIconNode.removeFromParentNode()
        sunNode.removeFromParentNode()
        iphoneNode.removeFromParentNode()

        //title
        titleStepLabel.text = titles[stepTap]
    }
    
    //MARK: - Actions
    @IBAction func preStep(_ sender: Any) {
        if stepTap > -1 {
        
            switch stepTap {
            case 0:
                workerNode.removeFromParentNode()
            case 1:
                xcodeIconNode.removeFromParentNode()
            case 2:
                spriteIconNode.removeFromParentNode()
            case 3:
                sceneIconNode.removeFromParentNode()
            case 4:
                sheepNode.removeFromParentNode()
            case 5:
                sunNode.removeFromParentNode()
            case 6:
                iphoneNode.removeFromParentNode()
            default:
                print("step \(stepTap)")
            }
            
            stepTap -= 1
            titleStepLabel.text = (stepTap < 0) ? "..." : titles[stepTap]

        }
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if stepTap < 7 {
            stepTap += 1
            titleStepLabel.text = (stepTap > 6) ? titles[6] : titles[stepTap]
            
            switch stepTap {
            case 0:
                workerNode.position = SCNVector3(0,0, -0.5)
                containerNode.addChildNode(workerNode)
            case 1:
                xcodeIconNode.position = SCNVector3(0, 1, -0.5)
                containerNode.addChildNode(xcodeIconNode)
            case 2:
                spriteIconNode.position = SCNVector3(-0.5, 0.5, -0.5)
                containerNode.addChildNode(spriteIconNode)
            case 3:
                sceneIconNode.position = SCNVector3(0.5, 0.5, -0.5)
                containerNode.addChildNode(sceneIconNode)
            case 4:
                sheepNode.position = SCNVector3(2, 0, -0.5)
                containerNode.addChildNode(sheepNode)
            case 5:
                sunNode.position = SCNVector3(1.5, 0.5, -0.5)
                containerNode.addChildNode(sunNode)
            case 6:
                iphoneNode.position = SCNVector3(2.5, 0.5, -0.5)
                containerNode.addChildNode(iphoneNode)
            default:
                print("step \(stepTap)")
            }
        }
    }
    
    @IBAction func resetStep(_ sender: Any) {
        resetSceneNodes()
        // step 0
        workerNode.position = SCNVector3(0,0, -0.5)
        containerNode.addChildNode(workerNode)
    }

}
