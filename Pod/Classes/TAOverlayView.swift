/*
Copyright © 2016 Toboggan Apps LLC. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import UIKit

/// View with a black, semi-transparent overlay that can have subtracted "holes" to view behind the overlay. 
/// Optionally add ``subtractedPaths`` to initialize the overlay with holes. More paths can be subtracted later using ``subtractFromView``.
public class TAOverlayView: UIView {
    
    /// The paths that have been subtracted from the view.
    fileprivate var subtractions: [UIBezierPath] = []
    
    /// Use to init the overlay.
    ///
    /// - parameter frame: The frame to use for the semi-transparent overlay.
    /// - parameter subtractedPaths: The paths to subtract from the overlay initially. These are optional (not adding them creates a plain overlay). More paths can be subtracted later using ``subtractFromView``.
    ///
    public init(frame: CGRect, subtractedPaths: [TABaseSubtractionPath]? = nil) {
        super.init(frame: frame)
        
        // Set a semi-transparent, black background.
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        
        // Create the initial layer from the view bounds.
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.fillColor = UIColor.black.cgColor
        
        let path = UIBezierPath(rect: self.bounds)
        maskLayer.path = path.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Set the mask of the view.
        self.layer.mask = maskLayer
        
        if let paths = subtractedPaths {
            // Subtract any given paths.
            self.subtractFromView(paths: paths)
        }
    }


    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Allow touches in "holes" of the overlay to be sent to the views behind it.
        for path in self.subtractions {
            if path.contains(point) {
                return false
            }
        }
        return true
    }
    
    /// Subtracts the given ``paths`` from the view.
    public func subtractFromView(paths: [TABaseSubtractionPath]) {
        if let layer = self.layer.mask as? CAShapeLayer, let oldPath = layer.path {
            // Start off with the old/current path.
            let newPath = UIBezierPath(cgPath: oldPath)
            
            // Subtract each of the new paths.
            for path in paths {
                self.subtractions.append(path.bezierPath)
                newPath.append(path.bezierPath)
            }
            
            // Update the layer.
            layer.path = newPath.cgPath
            self.layer.mask = layer
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
