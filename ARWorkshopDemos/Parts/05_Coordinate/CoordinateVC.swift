//
//  CoordinateVC.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/17/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import UIKit
import ARKit

class CoordinateVC: BaseViewController {
    
    @IBOutlet weak var sixDOFButton: UIButton!
    @IBOutlet weak var threeDOFButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    var isConfig3DOF = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadScence()
        
        // config buttons
        sixDOFButton.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
        threeDOFButton.backgroundColor = UIColor.clear
        sixDOFButton.layer.cornerRadius = 3.0
        sixDOFButton.layer.masksToBounds = true
        threeDOFButton.layer.cornerRadius = 3.0
        threeDOFButton.layer.masksToBounds = true
    }
    
    func loadConfig() {
        if !isConfig3DOF {
            let configuration = ARWorldTrackingConfiguration()
            sceneView.debugOptions = [.showWorldOrigin]
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            sceneView.debugOptions = [.showWorldOrigin]
            sceneView.session.run(configuration)
        }
    }
    @IBAction func dofButtonTouchUpInside(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 3 {
            if isConfig3DOF { return }
            threeDOFButton.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
            sixDOFButton.backgroundColor = UIColor.clear
        } else {
            if !isConfig3DOF { return }
            sixDOFButton.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
            threeDOFButton.backgroundColor = UIColor.clear
        }
        
        sceneView.session.pause()
        isConfig3DOF = !isConfig3DOF
        loadConfig()
    }
    
    //MARK: - Setup ARKit Screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //MARK: - Load scene
    func loadScence() {
        let gameScene = SCNScene(named: "Assets.scnassets/coordinateScene.scn")!
        sceneView.scene = gameScene
        let containerNode = gameScene.rootNode.childNode(withName: "container", recursively: false)!
        let iphone = containerNode.childNode(withName: "iphone", recursively: false)!
        iphone.position = SCNVector3(0, 0, -1)
        containerNode.position = SCNVector3(0, 0, 0)
    }

}
