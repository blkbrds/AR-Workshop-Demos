//
//  StatusView.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import ARKit

final class StatusView: UIView {
    
    enum MessageType {
        case trackingStateEscalation
        case planeEstimation
        case contentPlacement
        case focusSquare
        
        static var all: [MessageType] = [
            .trackingStateEscalation,
            .planeEstimation,
            .contentPlacement,
            .focusSquare
        ]
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak private var messagePanel: UIVisualEffectView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var restartExperienceButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    var restartExperienceHandler: () -> Void = {}
    private let displayDuration: TimeInterval = 6
    private var messageHideTimer: Timer?
    private var timers: [MessageType: Timer] = [:]
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StatusView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate()
        messageLabel.text = text
        setMessageHidden(false, animated: true)
        if autoHide {
            messageHideTimer = Timer.scheduledTimer(
                withTimeInterval: displayDuration,
                repeats: false,
                block: { [weak self] _ in
                    self?.setMessageHidden(true, animated: true)
                }
            )
        }
    }
    
    func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)
        let timer = Timer.scheduledTimer(
            withTimeInterval: seconds,
            repeats: false,
            block: { [weak self] timer in
                self?.showMessage(text)
                timer.invalidate()
            }
        )
        timers[messageType] = timer
    }
    
    func cancelScheduledMessage(`for` messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }
    
    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }
    
    func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
        showMessage(trackingState.presentationString, autoHide: autoHide)
    }
    
    func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)
        let timer = Timer.scheduledTimer(
            withTimeInterval: seconds,
            repeats: false,
            block: { [unowned self] _ in
                self.cancelScheduledMessage(for: .trackingStateEscalation)
                var message = trackingState.presentationString
                if let recommendation = trackingState.recommendation {
                    message.append(": \(recommendation)")
                }
                self.showMessage(message, autoHide: false)
            }
        )
        timers[.trackingStateEscalation] = timer
    }
    
    @IBAction private func restartExperience(_ sender: UIButton) {
        restartExperienceHandler()
    }
    
    private func setMessageHidden(_ hide: Bool, animated: Bool) {
        messagePanel.isHidden = false
        guard animated else {
            messagePanel.alpha = hide ? 0 : 1
            return
        }
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.messagePanel.alpha = hide ? 0 : 1
        }, completion: nil
        )
    }
    
}

extension ARCamera.TrackingState {
    
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(.excessiveMotion):
            return "TRACKING LIMITED\nExcessive motion"
        case .limited(.insufficientFeatures):
            return "TRACKING LIMITED\nLow detail"
        case .limited(.initializing), .limited(.relocalizing):
            return "Initializing"
        }
    }
    
    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface, or reset the session."
        default:
            return nil
        }
    }
    
}
