//
//  Extensions.swift
//  P4-InstaGrid
//
//  Created by Redouane on 10/07/2023.
//

import Foundation
import UIKit

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
