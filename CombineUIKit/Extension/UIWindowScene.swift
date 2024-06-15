//
//  UIWindowScene.swift
//  Created by HardiB.Salih on 6/15/24.
//

import UIKit

extension UIWindowScene {
    /// The current active UIWindowScene instance.
    static var current: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
    }
    
    /// The height of the screen associated with the UIWindowScene.
    var screenHeight: CGFloat {
        return self.screen.bounds.height
    }
    
    /// The width of the screen associated with the UIWindowScene.
    var screenWidth: CGFloat {
        return self.screen.bounds.width
    }
}

extension CGFloat {
    /// The height of the current screen.
    static var screenHeight: CGFloat { UIWindowScene.current?.screenHeight ?? 0 }
    
    /// The width of the current screen.
    static var screenWidth: CGFloat { UIWindowScene.current?.screenWidth ?? 0 }
}
