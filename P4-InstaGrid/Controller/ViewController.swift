//
//  ViewController.swift
//  P4-InstaGrid
//
//  Created by Redouane on 20/05/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainBlueView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet var layoutCollection: [UIButton]!
    @IBOutlet var plusButtonsCollection: [UIButton]!
    
    var swipeGesture: UISwipeGestureRecognizer?
    var currentPlusButtonSelected: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutCollection[2].setImage(UIImage(named: "Selected-1"), for: .normal)
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        swipeGesture?.direction = .up
        guard let swipeGesture = swipeGesture else { return }
        mainBlueView.addGestureRecognizer(swipeGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        getOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        getOrientation()
    }
    
    @objc func didSwipe() {
         
    }

    func getOrientation() {
        if UIDevice.current.orientation == .portrait {
            swipeLabel.text = "Swipe up to share"
            swipeGesture?.direction = .up
        } else {
            swipeLabel.text = "Swipe left to share"
            swipeGesture?.direction = .left
        }
    }
    
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        currentPlusButtonSelected = plusButtonsCollection[sender.tag - 1]
        selectImage()
    }
    
    
    func selectImage(){
        let alertVC = UIAlertController(title: "Image source", message: "Take a picture with camera or select one in your album", preferredStyle: .actionSheet)
        
        // Select picture from camera.
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            let cameraImagePicker = UIImagePickerController()
            cameraImagePicker.allowsEditing = true
            cameraImagePicker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                cameraImagePicker.sourceType = .camera
                self.present(cameraImagePicker, animated: true)
            }
        }
        
        // Select picture from library.
        let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in
            let libraryImagePicker = UIImagePickerController()
            libraryImagePicker.allowsEditing = true
            libraryImagePicker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                libraryImagePicker.sourceType = .photoLibrary
                self.present(libraryImagePicker, animated: true)
                libraryImagePicker.delegate = self
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        
        alertVC.addAction(cameraAction)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
    
    
    
/* ******************************** LAYOUT BUTTONS ************************************/

    @IBAction func layoutButton(_ sender: UIButton) {
        selectedLayout(sender)
    }
    
    func selectedLayout(_ sender: UIButton){
        let layoutImages = ["Layout 1", "Layout 2", "Layout 3"]
        for index in 0...layoutCollection.count - 1 {
            layoutCollection[index].setImage(UIImage(named: layoutImages[index]), for: .normal)
            layoutCollection[index].tintColor = .clear
        }
        layoutCollection[sender.tag-1].setImage(UIImage(named: "Selected-1"), for: .normal)
        layoutCollection[sender.tag-1].tintColor = .tintColor
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        guard let button = currentPlusButtonSelected else { return }
        button.setImage(selectedImage, for: .normal)
        self.dismiss(animated: true)
    }
}

