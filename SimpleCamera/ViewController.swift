//
//  ViewController.swift
//  SimpleCamera
//
//  Created by Corey Ferguson on 8/2/18.
//  Copyright © 2018 Corey Ferguson. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    var photoOutput: AVCapturePhotoOutput!
    var previewView: PreviewView!
    
    @objc
    func handleTouch(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings(format: nil)
        photoSettings.isAutoStillImageStabilizationEnabled = true
        if photoOutput.supportedFlashModes.contains(AVCaptureDevice.FlashMode.auto) {
            photoSettings.flashMode = .auto
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    override func loadView() {
        previewView = PreviewView()
        let button = UIButton(frame: previewView.bounds)
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.addTarget(self, action: #selector(handleTouch(_:)), for: .touchDown)
        previewView.addSubview(button)
        view = previewView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
            
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            // Use PHPhotoLibrary.shared().performChanges(...) to add assets.
        }
    }
    
    func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        // Connect inputs and outputs to the session
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .unspecified)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        // Display a camera preview
        self.previewView.videoPreviewLayer.session = captureSession
        /* let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewView.frame = self.view.bounds
        self.view.addSubview(previewLayer) */
        // Run the capture session
        captureSession.startRunning()
    }
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        /// Convenience wrapper to get layer as its statically known type.
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    // MARK: - Photo capture
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        label.text = "Taking..."
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.label.alpha = 1.0
        }).startAnimation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // guard error != nil else { print("Error capturing photo: \(error!)"); return }
        label.text = "Done!"
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.label.alpha = 0.0
        }).startAnimation()
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                // Add the captured photo's file data as the main resource for the Photos asset.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
            }, completionHandler: { success, error in
                if !success { NSLog("error creating asset: \(error!)") }
            })
        }
    }


}

