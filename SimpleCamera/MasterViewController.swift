//
//  MasterViewController.swift
//  SimpleCamera
//
//  Created by Corey Ferguson on 8/2/18.
//  Copyright © 2018 Corey Ferguson. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class MasterViewController: UIViewController, AVCapturePhotoCaptureDelegate {
        
    var photoOutput: AVCapturePhotoOutput!
    var stillImageData: Data!
    
    @IBAction func handleTouch(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings(format: nil)
        photoSettings.isAutoStillImageStabilizationEnabled = true
        if photoOutput.supportedFlashModes.contains(AVCaptureDevice.FlashMode.auto) {
            photoSettings.flashMode = .auto
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
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
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        // Run the capture session
        captureSession.startRunning()
    }
    
    // MARK: - Photo capture
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // guard error != nil else { print("Error capturing photo: \(error!)"); return }
        
        self.stillImageData = photo.fileDataRepresentation()
        
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! RootViewController
            controller.detailItem = stillImageData
        }
    }


}

