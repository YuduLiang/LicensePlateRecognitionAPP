import UIKit
import AVFoundation
import Vision

class ScanBaseViewController: UIViewController {

    fileprivate var session = AVCaptureSession()
    fileprivate var videoOutput = AVCaptureVideoDataOutput()
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var deviceInput: AVCaptureDeviceInput?
    
    lazy var cleanView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        getAuthorization()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        session.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
}


//MARK: setup view
extension ScanBaseViewController{
    fileprivate func setupViews(){
        view.backgroundColor = UIColor.black
        

        view.addSubview(cleanView)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: view.frame.height - 50, width: kScreenWidth, height: 50))
        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        cleanView.addSubview(bottomView)

    }
    
}


//MARK: add camera
extension ScanBaseViewController {
    fileprivate func getAuthorization(){
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if videoStatus == .authorized || videoStatus == .notDetermined{
            addScaningVideo()
        }else{
            print("no access to camera")
        }
    }
    
    fileprivate func addScaningVideo(){

        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        guard let deviceIn = try? AVCaptureDeviceInput(device: device) else { return }
        deviceInput = deviceIn
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        session.sessionPreset = .high
        
        if session.canAddInput(deviceInput!) {
            session.addInput(deviceInput!)
        }

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            guard let connection = videoOutput.connection(with: .video) else { return }

            if connection.isVideoOrientationSupported{
                connection.videoOrientation = .portrait
            }

            if connection.isVideoStabilizationSupported{
                connection.preferredVideoStabilizationMode = .auto
            }
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)

        if !session.isRunning {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
    }
}


extension ScanBaseViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
