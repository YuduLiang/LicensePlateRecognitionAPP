import UIKit
import Vision



class VisionTool: NSObject {
    typealias DetectHandle = ((_ bigRectArr: [CGRect]?, _ backArr: [Any]?) -> ())
    
}

//MARK: image recognition
extension VisionTool {
    /// recognise image
    func visionDetectImage(image: UIImage, _ completeBack: @escaping DetectHandle){
        //1. transform to ciimage
        guard let ciImage = CIImage(image: image) else { return }
        
        //2. create request handler
        let requestHandle = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        //3. create baseRequest
        var baseRequest = VNImageBasedRequest()
        
        
        let completionHandle: VNRequestCompletionHandler = { request, error in
            let observations = request.results
            self.handleImageObservable(image: image, observations, completeBack)
        }
        baseRequest = VNDetectTextRectanglesRequest(completionHandler: completionHandle)
        // set recognize character
        baseRequest.setValue(true, forKey: "reportCharacterBoxes")
        
        //5. send request
        DispatchQueue.global().async {
            do{
                try requestHandle.perform([baseRequest])
            }catch{
                print("Throws：\(error)")
            }
        }
    }

    /// data after recognition
    fileprivate func handleImageObservable(image: UIImage, _ observations: [Any]?, _ completionHandle: DetectHandle){
            textDectect(observations, image: image, completionHandle)
    }
}



//MARK: way of text recognition
extension VisionTool {
    /// word recognition
    fileprivate func textDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: DetectHandle){
        //1. get VNTextObservation
        guard let boxArr = observations as? [VNTextObservation] else { return }
        
        //2. create rect array
        var bigRects = [CGRect](), smallRects = [CGRect]()
        
        //3. traverse resognition result
        for boxObj in boxArr {

            bigRects.append(convertRect(boxObj.boundingBox, image))

            guard let rectangleArr = boxObj.characterBoxes else { continue }
            for rectangle in rectangleArr{
                //get size of each object
                let boundBox = rectangle.boundingBox
                smallRects.append(convertRect(boundBox, image))
            }
        }
        
        //4. send back result
        complecHandle(bigRects, smallRects)
    }
}


//MARK: coordinate transformation and add red rectangle
extension VisionTool{
    /// image coordinate transformation
    fileprivate func convertRect(_ rectangleRect: CGRect, _ image: UIImage) -> CGRect {
        let imageSize = image.scaleImage()
        let w = rectangleRect.width * imageSize.width
        let h = rectangleRect.height * imageSize.height
        let x = rectangleRect.minX * imageSize.width

        let y = (1 - rectangleRect.minY) * imageSize.height - h
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// rect coordinate transform
    func convertRect(_ rectangleRect: CGRect, _ rect: CGRect) -> CGRect {
        let size = rect.size
        let w = rectangleRect.width * size.width
        let h = rectangleRect.height * size.height
        let x = rectangleRect.minX * size.width

        let y = (1 - rectangleRect.maxY) * size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// transform to layer coordinates
    func convertRect(viewRect: CGRect, layerRect: CGRect) -> CGRect{
        let size = layerRect.size
        let w = viewRect.width / size.width
        let h = viewRect.height / size.height
        let x = viewRect.minX / size.width
        let y = 1 - viewRect.maxY / size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}




