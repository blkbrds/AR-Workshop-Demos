//
//  HomeVC.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/7/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    let demos = ["Introduction",
                 "ARKit",
                 "Environment",
                 "2D & 3D",
                 "Coordinate system",
                 "A Solar System",
                 "Shooter AR game",
                 "Danbo Sumburai 3d AR game"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR Workshop"
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1). \(demos[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let vc = IntroductionVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = WhatARKitVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = EnvironmentVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = GraphicsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = CoordinateVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = SolarSystemViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            print("Nothing")
        }
    }
}
