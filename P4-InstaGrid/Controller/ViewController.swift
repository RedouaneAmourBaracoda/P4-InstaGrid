//
//  ViewController.swift
//  P4-InstaGrid
//
//  Created by Redouane on 20/05/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var mainBlueView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet var layoutCollection: [UIButton]!
    @IBOutlet var plusButtonsCollection: [UIButton]!

    var swipeGesture: UISwipeGestureRecognizer?
    var appropriateTranslation: CGAffineTransform?
    var currentPlusButtonSelected: UIButton?
    var plusButtonsAlreadySelected: [UIButton] = []
    var currentLayout: Layout = .layout3
    var canToggle: Bool = false {
        didSet {
            if canToggle == true {
                toggleButton.isHidden = false
            } else {
                toggleButton.isHidden = true
            }
        }
    }
    
    var toggleUpStatus: Bool = false
    var toggleDownStatus: Bool = false
    
    enum Layout {
        case layout1
        case layout2
        case layout3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutCollection[2].setImage(UIImage(named: "Selected-1"), for: .normal)
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        getOrientation()
        guard let swipeGesture = swipeGesture else { return }
        mainBlueView.addGestureRecognizer(swipeGesture)
        toggleButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(getOrientation), name: name, object: nil)
    }
    
    // NB: For unknown reason, device orientation state remains unexpectedly ".unknown" when the app starts. In that case, we intentionnaly set swipe up direction. So if device starts in landscape mode, you might need to swipe up and not left.
    @objc func getOrientation() {
        let orientation = UIDevice.current.orientation
        if orientation == .portrait || orientation == .unknown {
            swipeLabel.text = "Swipe up to share"
            swipeGesture?.direction = .up
            appropriateTranslation = CGAffineTransformMakeTranslation(0, -700)
        } else {
            swipeLabel.text = "Swipe left to share"
            swipeGesture?.direction = .left
            appropriateTranslation = CGAffineTransformMakeTranslation(-700, 0)
        }
    }

    @objc func didSwipe() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: [], animations: {
            guard let translation = self.appropriateTranslation else { return }
            self.mainBlueView.transform = translation
        }) { _ in
            self.share()
        }
    }

    private func share() {
        guard let image = mainBlueView.TransformMainBlueViewToSharableImage else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            UIView.animate(withDuration: 0.5) {
                self.mainBlueView.transform = .identity
            }
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
            self.plusButtonsAlreadySelected.removeAll { $0.tag == self.currentPlusButtonSelected?.tag }
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
        clearLayoutImages()
        layoutCollection[sender.tag-1].setImage(UIImage(named: "Selected-1"), for: .normal)
        layoutCollection[sender.tag-1].tintColor = .tintColor
        
        for button in plusButtonsCollection {
            button.isHidden = false
        }
        switch sender.tag {
        case 1:
            currentLayout = .layout1
            adaptLayout(firstIndex: 0, secondIndex: 1)
        case 2:
            currentLayout = .layout2
            adaptLayout(firstIndex: 2, secondIndex: 3)
        default:
            currentLayout = .layout3
            canToggle = false
            for button in plusButtonsAlreadySelected {
                button.isHidden = false
            }
        }
    }

    func clearLayoutImages() {
        let layoutImages = ["Layout 1", "Layout 2", "Layout 3"]
        for index in 0...layoutCollection.count - 1 {
            layoutCollection[index].setImage(UIImage(named: layoutImages[index]), for: .normal)
            layoutCollection[index].tintColor = .clear
        }
    }

    func adaptLayout(firstIndex: Int, secondIndex: Int) {
        let firstTag: Int = firstIndex + 1
        let secondTag: Int = secondIndex + 1
        var buttonsSelected: [UIButton] = []
        for button in plusButtonsAlreadySelected {
            if button.tag == firstTag || button.tag == secondTag {
                buttonsSelected.append(button)
            }
        }
        
        if buttonsSelected.count == 0 {
            plusButtonsCollection[secondIndex].isHidden = true
            canToggle = false
        } else if buttonsSelected.count == 1 {
            if buttonsSelected[0].tag == firstTag {
                plusButtonsCollection[secondIndex].isHidden = true
                canToggle = false
            } else {
                plusButtonsCollection[firstIndex].isHidden = true
                canToggle = false
            }
        } else { // 2 pictures: can toggle.
            plusButtonsCollection[secondIndex].isHidden = true
            canToggle = true
        }
    }

    @IBAction func toggleTapped(_ sender: UIButton) {
        switch currentLayout {
        case .layout1:
            swapImages(toggleUpStatus, .layout1)
            toggleUpStatus.toggle()
        case .layout2:
            swapImages(toggleDownStatus, .layout2)
            toggleDownStatus.toggle()
        case .layout3:
            break
        }
    }
    
    func swapImages(_ toggleStatus: Bool, _ layout: Layout){
        let firstIndex: Int
        let secondIndex: Int
        if layout == .layout1 {
            firstIndex = 0
            secondIndex = 1
        } else {
            firstIndex = 2
            secondIndex = 3
        }
        if toggleStatus {
            plusButtonsCollection[firstIndex].isHidden = false
            plusButtonsCollection[secondIndex].isHidden = true
        } else {
            plusButtonsCollection[firstIndex].isHidden = true
            plusButtonsCollection[secondIndex].isHidden = false
        }
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        for button in plusButtonsCollection {
            button.setImage(UIImage(named: "Plus"), for: .normal)
        }
        selectedLayout(layoutCollection[2])
        plusButtonsAlreadySelected.removeAll()
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        guard let button = currentPlusButtonSelected else { return }
        button.setImage(selectedImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        self.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.plusButtonsAlreadySelected.removeAll { $0.tag == self.currentPlusButtonSelected?.tag }
        self.dismiss(animated: true)
    }
}

extension UIView {
    /// allows to transform the myMainBlueView grid scafold into a simple image 2D
    var TransformMainBlueViewToSharableImage: UIImage? {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image // image flattened
    }
}

