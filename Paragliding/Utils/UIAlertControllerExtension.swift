//
//  UIAlertViewControllerExtension.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 07/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit

extension UIAlertController {

    public func show(animated: Bool = true, hapticFeedback: Bool = false, completion: (() -> Void)? = nil) {
        if hapticFeedback {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        show(animated: true, vibrate: false, completion: completion)
    }
}
