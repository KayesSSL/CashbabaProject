//
//  FaceDetectionViewController.swift
//  CBFaceDetection
//
//  Created by Mausum Nandy on 25/4/24.
//

import UIKit
import AVFoundation
import Vision

class FaceDetectionViewController: UIViewController {
    var sequenceHandler = VNSequenceRequestHandler()
    lazy var  contentView : FaceDetectionView = {
        let contentView = FaceDetectionView()
        contentView.backButton.addTarget(self, action: #selector(backAction) , for: .touchUpInside)
        
        contentView.navTitle.text = strings?["nav_title"] ?? "Face Verification"
        
         contentView.recordLabel.text = strings?["title_2"] ?? "Record a Selfie Video"
        contentView.messageLabel.text = strings?["title_3"] ??  "Start by positioning your face in the frame."
        
        contentView.recordLabel.text = strings?["smile"] ?? "Smile"
        contentView.imageSmile.label.text = strings?["smile"] ?? "Smile"
        contentView.imageBlink.label.text = strings?["blink"] ?? "Eye Blink"
       
        
        contentView.preview.addSubview(activityView)
        activityView.addAnchorToSuperview(centeredVertically: 0,centeredHorizontally: 0)
        
        
        return contentView
    }()
    var delegate: CBFaceDetectionSDKDelegate?
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let activityView = UIActivityIndicatorView(style: .large)
    var strings : [String:String]?
    var blinkImage: UIImage?
    {
        didSet{
            
            self.blinkImage?.cgImage?.faceCrop(margin:250,completion: { result in
                switch result{
                case .failure(_),.notFound:
                    break
                case .success(let cgImage):
                    DispatchQueue.main.async {
                        self.contentView.imageBlink.stopAnimation()
                        self.contentView.imageBlink.containter.layer.borderColor = UIColor(red: 0.139, green: 0.694, blue: 0, alpha: 1).cgColor
                        self.contentView.imageBlink.imageView.image = UIImage(cgImage: cgImage)
                        self.contentView.imageBlink.imageView.contentMode = .scaleAspectFit
                        self.contentView.imageBlink.label.textColor =  UIColor(red: 0.139, green: 0.694, blue: 0, alpha: 1)
                        self.contentView.indicatorView.step = 3
                        self.activityView.stopAnimating()
                        self.checkCallBack()
                    }
                }
                
            })
        }
    }
    var smileImage: UIImage?{
        didSet{
            self.smileImage?.cgImage?.faceCrop(margin:250,completion: { result in
                switch result{
                case .failure(_),.notFound:
                    break
                case .success(let cgImage):
                    DispatchQueue.main.async {
                        self.contentView.imageSmile.stopAnimation()
                        self.contentView.imageBlink.blinkBorder()
                        self.contentView.recordLabel.text = self.strings?["blink"] ?? "Eye Blink"
                        self.contentView.imageSmile.containter.layer.borderColor =  UIColor(red: 0.139, green: 0.694, blue: 0, alpha: 1).cgColor
                        self.contentView.imageSmile.imageView.image = UIImage(cgImage: cgImage)
                        self.contentView.imageSmile.imageView.contentMode = .scaleAspectFit
                        self.contentView.imageSmile.label.textColor = UIColor(red: 0.139, green: 0.694, blue: 0, alpha: 1)
                        self.contentView.indicatorView.step = 1
                        self.activityView.stopAnimating()
                        self.checkCallBack()
                    }
                }
                
            })
        }
    }
    
    
    
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = contentView
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
            
            self.configureCaptureSession()
            
            self.contentView.preview.layer.cornerRadius = self.contentView.preview.frame.width/2
            self.contentView.preview.clipsToBounds = true
            
            self.contentView.falseView.layer.cornerRadius = self.contentView.falseView.frame.width/2
            
            self.contentView.indicatorView.layer.cornerRadius = self.contentView.indicatorView.frame.width/2
            self.contentView.indicatorView.clipsToBounds = true
            
        })
        
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        
    }
    
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            fatalError("No front video camera available")
        }
        
        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        contentView.preview.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = contentView.preview.bounds
    }
    
    var currentImage : UIImage!
    var processing : Bool = false
    @objc func backAction(){
        self.dismiss(animated: true) {
            self.delegate?.userCancelled("user closed")
        }
    }
    func checkCallBack(){
        guard let imageBlink = self.blinkImage, let imageSmile = self.smileImage else{
            return
        }
        self.session.stopRunning()
        self.dismiss(animated: true) {
            self.delegate?.images(smile: imageSmile.base64String, blink: imageBlink.base64String)
        }
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // 1
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            
            guard let outputImage = self.getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
                return
            }
            
            self.currentImage = outputImage
            guard let buffer =   self.buffer(from: self.currentImage) else {
                return
            }
            
            // 2
            let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: self.detectedFace)
            do {
                try self.sequenceHandler.perform(
                    [detectFaceRequest],
                    on:buffer,
                    orientation: .leftMirrored)
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    
    
    
    // MARK: - Face Side detection Codes
    
    func detectedFace(request: VNRequest, error: Error?) {
        
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
        else {
            return
        }
        
        updateFaceView(for: result)
        
    }
    
    
    
    func updateFaceView(for result: VNFaceObservation) {
        
        
        guard let landmarks = result.landmarks else {
            return
        }
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.contentView.preview.frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: self.view.frame.width, y: self.contentView.preview.frame.height)
        
        let facebounds = result.boundingBox.applying(translate).applying(transform)
        //   print(facebounds)
        guard  (facebounds.midX < contentView.preview.center.x + 20) else {
            return
        }
        
        
        
        /*Face Detection*/
        
        if   let points = landmarks.medianLine?.normalizedPoints,
             let top = points.first,
             let center = points.last,
             let outerLips = landmarks.outerLips,
             let innerLips = landmarks.innerLips,
             let leftEye = landmarks.leftEye , let righEye = landmarks.rightEye ,
             points.count > 2 {
            let count = points.count
            let bottom = points[count - 2]
            let v2 = CGVector(dx: top.x - center.x, dy: top.y - center.y)
            let v1 = CGVector(dx: bottom.x - center.x, dy: bottom.y - center.y)
            let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
            let angleDegrees = angle * CGFloat(180.0 / .pi)
            //print(angleDegrees)
            if angleDegrees > -1 && angleDegrees < 1  {
                print(angleDegrees)
                if self.smileImage == nil,( aspectRatio(of: leftEye) > 20 ||  aspectRatio(of: righEye) >  20){
                    // Calculate the distance between outerLips and innerLips
                    let lipDistance = distanceBetween(outerLips, innerLips)*100
                    
                    print("lip distance",lipDistance)
                    // If the lip distance is small (indicating a smile), handle accordingly
                    if lipDistance > 0.4 {
                        // Handle smile detection here (e.g., show a smile emoji)
                        print("Smile detected!")
                        
                        self.smileImage = self.currentImage
                    }
                }else if self.smileImage != nil ,  self.blinkImage == nil,  distanceBetween(outerLips, innerLips)*100 < 0.4{
                    if aspectRatio(of: leftEye) < 18 ||  aspectRatio(of: righEye) < 18{
                        print("eye closed")
                        
                        self.blinkImage = self.currentImage
                    }
                }
                
                
            }
        }
    }
    
    func aspectRatio(of eye: VNFaceLandmarkRegion2D) -> Float {
        let points = eye.normalizedPoints
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        let width = xs.max()! - xs.min()!
        let height = ys.max()! - ys.min()!
        return Float(width / height)*100
    }
    
    func distanceBetween(_ region1: VNFaceLandmarkRegion2D, _ region2: VNFaceLandmarkRegion2D) -> Float {
        // Calculate the centroids of each region
        let centroid1 = centroid(of: region1)
        let centroid2 = centroid(of: region2)
        
        // Calculate the distance between the centroids
        let dx = centroid2.x - centroid1.x
        let dy = centroid2.y - centroid1.y
        return sqrt(dx*dx + dy*dy)
    }
    
    func centroid(of region: VNFaceLandmarkRegion2D) -> (x: Float, y: Float) {
        let points = region.normalizedPoints
        let sum = points.reduce((x: 0, y: 0)) { (result, point) in
            (x: result.x + Float(point.x), y: result.y + Float(point.y))
        }
        let count = Float(points.count)
        return (x: sum.x / count, y: sum.y / count)
    }
    
    // MARK: - Util method
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.upMirrored)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
