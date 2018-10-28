import UIKit
import Foundation
import Vision

//MARK: global parameters
/// global image vision tool
let visionTool = VisionTool()
/// global image processing tool
let viewTool = ViewTool()
/// screen width
let kScreenWidth = UIScreen.main.bounds.size.width
/// screen height
let kScreenHeight = UIScreen.main.bounds.size.height

let imageViewScale: CGFloat = 125 / 161

extension UIImage {
    func scaleImage0(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage0 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage0
    }
}


//MARK: UIImage
extension UIImage{
    /// compress image
    public func scaleImage() -> CGSize {
        //image aspect ratio
        let imageScale = size.width / size.height
        var imageWidth: CGFloat = 1
        var imageHeight: CGFloat = 1
        if imageScale >= imageViewScale {
            imageWidth = kScreenWidth
            imageHeight = imageWidth / imageScale
        }else{
            imageHeight = kScreenWidth / imageViewScale
            imageWidth = imageHeight * imageScale
        }
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
}

extension UIImage {
    func scaleToSize(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
//MARK: String
extension String {
    public func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        if self.isEmpty { return }
        
        for view in window.subviews where view.tag == 33 {
            view.removeFromSuperview()
        }
        let blackView = UIView()
        blackView.backgroundColor = UIColor.black
        blackView.layer.cornerRadius = 2
        blackView.layer.masksToBounds = true
        blackView.tag = 33
        window.addSubview(blackView)
        
        let textLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 0, height: 0))
        textLabel.text = self
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.backgroundColor = UIColor.clear
        textLabel.font = UIFont.systemFont(ofSize: 14)
        blackView.addSubview(textLabel)
        
        let size = (self as NSString).boundingRect(with: CGSize(width: kScreenWidth / 3 * 2, height: CGFloat(HUGE)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil).size
        textLabel.frame = CGRect(x: 10, y: 5, width: size.width, height: size.height)
        blackView.frame = CGRect(x: (kScreenWidth - textLabel.frame.width - 20) / 2, y: (kScreenHeight - textLabel.frame.height - 10) / 2, width: textLabel.frame.width + 20, height: textLabel.frame.height + 10)
        
        UIView.animate(withDuration: 0.5, delay: 3, options: .curveLinear, animations: {
            blackView.alpha = 0
        }) { (finished) in
            blackView.removeFromSuperview()
        }
    }
}
