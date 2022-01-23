//
//  UIView+FadeAnimation.swift
//  SimpleWeatherApp
//
//  Created by Сашок on 23.01.2022.
//

import UIKit

extension UIView {
    func startFadeAnimation() {
        UIView.animate(withDuration: 0.85, delay: 0, options: [.repeat, .autoreverse] ) {
            self.alpha = 0
        }
    }
    
    func stopFadeAnimation() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
