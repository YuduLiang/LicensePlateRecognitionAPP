import UIKit
import SwiftyJSON
import AFNetworking

class DectectBaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    ///image select from album
    var selectorImage: UIImage?
    var imageView = UIImageView()
    var textField = UILabel(frame: CGRect(x: 50, y: kScreenHeight - 120, width: kScreenWidth - 100, height: 30))
    var nameField = UILabel(frame: CGRect(x: 50, y: kScreenHeight - 80, width: kScreenWidth - 100, height: 30))
    lazy var cleanView: UIView = {
        guard let imageSize = selectorImage?.scaleImage() else { return UIView() }
        let cleanVIew = UIView()
        cleanVIew.backgroundColor = UIColor.clear
        return cleanVIew
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVIews()
    }
    
    
    ///setup view
    func setupVIews(){
        view.backgroundColor = UIColor.white
        view.addSubview(textField)
        view.addSubview(nameField)
        textField.backgroundColor = UIColor.lightGray
        nameField.backgroundColor = UIColor.lightGray
        view.addSubview(addButton(title: "select from album", rect: CGRect(x: 50, y: 100, width: kScreenWidth - 100, height: 30), action: #selector(selectedImageAction(_:))))
        view.addSubview(addButton(title: "take a photo", rect: CGRect(x: 50, y: 150, width: kScreenWidth - 100, height: 30), action: #selector(selectedCameraAction(_:))))
        view.addSubview(addButton(title: "start recognition", rect: CGRect(x: 50, y: kScreenHeight - 200, width: kScreenWidth - 100, height: 30), action: #selector(startRecognitionAction(_:))))
        view.addSubview(addButton(title: "Request Message", rect: CGRect(x: 50, y: kScreenHeight - 160, width: kScreenWidth - 100, height: 30), action: #selector(requestFromSql(_:))))
        
        imageView.frame = CGRect(x: 0, y: 200, width: kScreenWidth, height: kScreenWidth)
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.addSubview(cleanView)
    }
    
    ///access camera
    func useringCamera(){
        //1. decide whether permit this operation
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("not executable")
            return
        }
        //2. create image picker controller
        let imagePC = UIImagePickerController()
        //2.1 set data source
        imagePC.sourceType = .camera
        //2.2 set delegate
        imagePC.delegate = self
        //2.3
        present(imagePC, animated: true, completion: nil)
    }
    
    ///access album
    func useringPhotoLibrary(){
        //1. decide whether permit this operation
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("not executable")
            return
        }
        //2. create image picker controller
        let imagePC = UIImagePickerController()
        //2.1 set data source
        imagePC.sourceType = .photoLibrary
        //2.2 set delegate
        imagePC.delegate = self
        //2.3
        present(imagePC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //get image selected
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        selectorImage = image
        imageView.image = image
        
        //exit controller
        picker.dismiss(animated: true, completion: nil)
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: UI management
extension DectectBaseViewController{
    fileprivate func addButton(title: String, rect: CGRect, action: Selector) -> UIButton{
        let button = UIButton(type: .custom)
        button.frame = rect
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    //select image
    @objc func selectedImageAction(_ sender: Any) {
        //0. delete red rectangle
        for subview in cleanView.subviews {
            subview.removeFromSuperview()
        }
        //1. select from album
        useringPhotoLibrary()
    }
    
    //select photo image
    @objc func selectedCameraAction(_ sender: Any) {
        //0. delete red rectangle
        for subview in cleanView.subviews {
            subview.removeFromSuperview()
        }
        //1. select from camera
        useringCamera()
    }
    
    //start recognition
    @objc func startRecognitionAction(_ sender: Any) {
        //0. delete red rectangle
        for subview in cleanView.subviews {
            subview.removeFromSuperview()
        }
        
        //1. get image with same size
        guard let image = selectorImage else { return }
        
        //2. change cleanView size
        let imageSize = image.scaleImage()
        cleanView.frame = CGRect(x: (kScreenWidth - imageSize.width) / 2, y: (kScreenWidth - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
    }
    @objc func requestFromSql(_ sender: Any) {
        let loginUrl = "http://10.0.0.1:8888/CarRegister.php"
        let params = ["licence":self.textField.text]
        NetworkTools.shareInstance.request(methodType: .GET, urlString: loginUrl, parameters: params as [String : AnyObject]) { (result : AnyObject?, error : Error?) in
            
            if error != nil  {
                print(error!)
                return
            }
            let json = JSON(result as Any)
            self.nameField.text = json["name"].string
        }
    }
}
