import UIKit
import Vision
import AVFoundation

class ViewTool: NSObject {

}

extension ViewTool{
    /// add red rectangle view
    func addRectangleView(rect: CGRect, _ position: AVCaptureDevice.Position = .back) -> UIView {

        let x = position == .back ? rect.minX : rect.width - rect.maxX
        let boxView = UIView(frame: CGRect(x: x, y: rect.minY, width: rect.width, height: rect.height))
        boxView.backgroundColor = UIColor.clear
        boxView.layer.borderColor = UIColor.red.cgColor
        boxView.layer.borderWidth = 2
        return boxView
    }
    
    
    /// add red rectangle layer
    func addRectangleLayer(rect: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = rect
        boxLayer.cornerRadius = 3
        boxLayer.borderColor = UIColor.red.cgColor
        boxLayer.borderWidth = 1.5
        return boxLayer
    }
}
