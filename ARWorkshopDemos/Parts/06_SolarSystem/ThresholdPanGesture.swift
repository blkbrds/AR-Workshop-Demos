//
//  ThresholdPanGesture.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

final class ThresholdPanGesture: UIPanGestureRecognizer {
    
    private(set) var isThresholdExceeded = false
    
    override var state: UIGestureRecognizer.State {
        didSet {
            switch state {
            case .began, .changed:
                break
            default:
                isThresholdExceeded = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        let translationMagnitude = translation(in: view).length
        let threshold = ThresholdPanGesture.threshold(forTouchCount: touches.count)
        if !isThresholdExceeded && translationMagnitude > threshold {
            isThresholdExceeded = true
            setTranslation(.zero, in: view)
        }
    }
    
    private static func threshold(forTouchCount count: Int) -> CGFloat {
        switch count {
        case 1: return 30
        default: return 60
        }
    }
    
}
