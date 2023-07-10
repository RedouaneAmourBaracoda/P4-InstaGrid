//
//  Extensions.swift
//  P4-InstaGrid
//
//  Created by Redouane on 10/07/2023.
//

import Foundation
import UIKit

extension UIView {
    /// allows to transform the myMainBlueView grid scafold into a simple image 2D
    var TransformMainBlueViewToSharableImage: UIImage? {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image // image flattened
    }
}
