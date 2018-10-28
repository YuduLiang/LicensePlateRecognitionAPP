import UIKit
import TesseractOCR
import GPUImage
import AFNetworking
import SwiftyJSON

//import SwiftOCR

extension String {
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
}

class ViewController: DectectBaseViewController {
    
    static func rotateImage(_ image: UIImage, withAngle angle: Double) -> UIImage? {
        if angle.truncatingRemainder(dividingBy: 360) == 0 { return image }
        let imageRect = CGRect(origin: .zero, size: image.size)
        let radian = CGFloat(angle / 180 * Double.pi)
        let rotatedTransform = CGAffineTransform.identity.rotated(by: radian)
        var rotatedRect = imageRect.applying(rotatedTransform)
        rotatedRect.origin.x = 0
        rotatedRect.origin.y = 0
        UIGraphicsBeginImageContext(rotatedRect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)
        context.rotate(by: radian)
        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
        image.draw(at: .zero)
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    
    func performImageRecognition(_ image: UIImage) -> String{
            // 1
        if let tesseract = G8Tesseract(language: "eng") {
            // 2
            tesseract.engineMode = .tesseractOnly
            // 3
            tesseract.pageSegmentationMode = .singleColumn
            // 4
            tesseract.image = image.g8_blackAndWhite()
            // 5
            let angle = tesseract.deskewAngle
            tesseract.image = ViewController.rotateImage(image.g8_blackAndWhite(), withAngle: Double(angle))
            tesseract.recognize()
            return tesseract.recognizedText
        }
        return "?"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    
    
    //start recognition
    @objc override func startRecognitionAction(_ sender: Any) {
        super.startRecognitionAction(sender)
        var bigestRects = CGRect()
        //var charRects = [CGRect]()
        //var charImage = [UIImage]()
        let thresholdDisposal = LuminanceThreshold()
        
        LuminanceThreshold().threshold = 0.4
        var result = String()
        guard let image = selectorImage else { return }
        visionTool.visionDetectImage(image: image) { (bigRects, smallRects)  in
            //large area recognized
            guard let rectArr = bigRects else { return }
            for textRect in rectArr{
                if Float(textRect.width) * Float(textRect.height) > Float(bigestRects.width) * Float(bigestRects.height){
                    bigestRects = textRect
                }
            }
            let width = bigestRects.width
            let height = bigestRects.height
            let x = bigestRects.minX
            let y = bigestRects.minY
            
            bigestRects.size = CGSize(width:width+10,height:height+8)
            bigestRects.origin = CGPoint(x: x-5, y: y-4)
            
            
            
            
            DispatchQueue.main.async {
                self.cleanView.addSubview(viewTool.addRectangleView(rect: bigestRects))
            }
//            guard let smallArr = smallRects as? [CGRect] else { return }
//            for textRect in smallArr{
//                if bigestRects.contains(textRect.origin){
//                    if textRect.height > bigestRects.height/2{
//                        charRects.append(textRect)
//                    }
//                }
//            }
            
            
            print(bigestRects.width)
            self.cleanView.addSubview(viewTool.addRectangleView(rect: bigestRects))
            let fitSizeImage =  image.scaleToSize(size:image.scaleImage())
            print(fitSizeImage.size.height)
            
//            for textRect in charRects{
//                let cgImageCorpped0 = self.cropImage(image, toRect: textRect, viewWidth: fitSizeImage.size.width, viewHeight: fitSizeImage.size.height)
//                charImage.append(cgImageCorpped0!)
//            }
            
            
            let cgImageCorpped = self.cropImage(image, toRect: bigestRects, viewWidth: fitSizeImage.size.width, viewHeight: fitSizeImage.size.height)
            
            let scaledImage = cgImageCorpped?.scaleImage0(640)
            
            
            
            //            var scaledImage0 = charImage[0].scaleImage0(640)
            //            var filteredImage: UIImage = scaledImage0!.filterWithOperation(thresholdDisposal)
            //            result.append(self.performImageRecognition(filteredImage))
            //            let a = charImage[1]
            //            for char in charImage{
            //                var scaledImage0 = char.scaleImage0(640)
            //                var filteredImage: UIImage = scaledImage0!.filterWithOperation(thresholdDisposal)
            //                result.append(self.performImageRecognition(a))
            //            }
            
            if scaledImage != nil{
                let filteredImage: UIImage = scaledImage!.filterWithOperation(thresholdDisposal)
                result = self.performImageRecognition(filteredImage)
                
                let pattern = "[^a-zA-Z0-9]"
                let ns = result.pregReplace(pattern: pattern, with: "")
                //let final=(ns as NSString).substring(to: 6)
                self.textField.text = ns
               
            }

        }
    }
}
