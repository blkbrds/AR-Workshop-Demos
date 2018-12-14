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
        workerNode.isHidden = false
    }
    
    func resetSceneNodes() {
        stepTap = 0
        
        //remove nodes
        xcodeIconNode.isHidden = true
        sheepNode.isHidden = true
        xcodeIconNode.isHidden = true
        spriteIconNode.isHidden = true
        sceneIconNode.isHidden = true
        sunNode.isHidden = true
        iphoneNode.isHidden = true

        //title
        titleStepLabel.text = titles[stepTap]
    }
    
    //MARK: - Actions
    @IBAction func preStep(_ sender: Any) {
        if stepTap > -1 {
        
            switch stepTap {
            case 0:
                workerNode.isHidden = true
            case 1:
                xcodeIconNode.isHidden = true
            case 2:
                spriteIconNode.isHidden = true
            case 3:
                sceneIconNode.isHidden = true
            case 4:
                sheepNode.isHidden = true
            case 5:
                sunNode.isHidden = true
            case 6:
                iphoneNode.isHidden = true
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
                workerNode.isHidden = false
            case 1:
                xcodeIconNode.position = SCNVector3(0, 1, -0.5)
                xcodeIconNode.isHidden = false
            case 2:
                spriteIconNode.position = SCNVector3(-0.5, 0.5, -0.5)
                spriteIconNode.isHidden = false
            case 3:
                sceneIconNode.position = SCNVector3(0.5, 0.5, -0.5)
                sceneIconNode.isHidden = false
            case 4:
                sheepNode.position = SCNVector3(2, 0, -0.5)
                sheepNode.isHidden = false
            case 5:
                sunNode.position = SCNVector3(1.5, 0.5, -0.5)
                sunNode.isHidden = false
            case 6:
                iphoneNode.position = SCNVector3(2.5, 0.5, -0.5)
                iphoneNode.isHidden = false
            default:
                print("step \(stepTap)")
            }
        }
    }
    
    @IBAction func resetStep(_ sender: Any) {
        resetSceneNodes()
        // step 0
        workerNode.position = SCNVector3(0,0, -0.5)
        workerNode.isHidden = false
    }

}
