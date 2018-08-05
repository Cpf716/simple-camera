//
//  DetailViewController.swift
//  SimpleCamera
//
//  Created by Corey Ferguson on 8/4/18.
//  Copyright © 2018 Corey Ferguson. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    func configureView() {
        if let detail = detailItem {
            if let imageView = detailImageView {
                imageView.image = UIImage(data: detail)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureView()
    }
    
    var detailItem: Data? {
        didSet {
            configureView()
        }
    }
    
    @IBAction func savePhotoToPhotosLibrary(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                // Add the captured photo's file data as the main resource for the Photos asset.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: self.detailItem!, options: nil)
            }, completionHandler: { success, error in
                if !success { NSLog("error creating asset: \(error!)") }
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func dismissViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
