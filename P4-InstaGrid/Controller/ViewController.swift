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
    var plusButtonsAlreadySelected: [UIButton] = []
    
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
        super.viewWillTransition(to: size, with: coordinator)
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
        guard let button = currentPlusButtonSelected else { return }
        if !buttonAlreadySelected(sender) { plusButtonsAlreadySelected.append(button) }
        selectImage()
    }
    
    func buttonAlreadySelected(_ sender: UIButton) -> Bool {
        var output: Bool = false
        for button in plusButtonsAlreadySelected {
            if button.tag == sender.tag {
                output = true
                break
            }
        }
        return output
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
        changeCentralView(sender)
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
    
    func changeCentralView(_ sender: UIButton){
        for button in plusButtonsCollection {
            button.isHidden = false
        }
        
        switch sender.tag {
        case 1: adaptLayout1()
        case 2: adaptLayout2()
        default: break
        }
    }
    
///     Adapt layout for the two plus buttons at the top.
    func adaptLayout1() {
        var topButtons: [UIButton] = []
        for button in plusButtonsAlreadySelected {
            if button.tag == 1 || button.tag == 2 {
                topButtons.append(button)
            }
        }
        
    }
///     Adapt layout for plus buttons at the bottom.
    func adaptLayout2() {
        
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

