//
//  ext_MainControllerBadgePhoto.swift
//  TheKind
//
//  Created by Tenny on 12/24/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit


extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //TODO: THis is a hacked version for test. Uncomment below for the real one.
    func hitPickerControl() {
        self.hudView.userPictureImageVIew.image = #imageLiteral(resourceName: "userPhoto")

        let txt = "Let me show how you look like.-Look up ☝️."
        let actions: [KindActionType] = [.none, .activate]
        let actionViews: [ActionViewName] = [.none,.HudView]

        // TODO: all should look like this one.
        let options = self.talkbox.createUserOptions(opt1: "Take another one.", opt2: "Keep this one.", actionViews: (.BadgePhotoSetupView,.BadgePhotoSetupView))


        self.talkbox.displayRoutine(routine: self.talkbox.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options), wait: 1)

    }
    
//    func hitPickerControl() {
//        let pickerController = UIImagePickerController()
//        pickerController.allowsEditing = true
//        //pickerController.cameraOverlayView = OVERLAY!!
//        pickerController.sourceType = .camera
//        pickerController.cameraCaptureMode = .photo
//        pickerController.delegate = self
//        pickerController.cameraDevice = .front
//        present(pickerController, animated: true)
//
//    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.jungChatLogger.HoldToAnswerViewWidthAnchor.constant = 0
        dismiss(animated: true)
    }
    

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        dismiss(animated: true)

        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }

        let badgeSelfieImage:Data = image.jpegData(compressionQuality: 0.2)!

        let jungAWSRekognition = JungAWSRekognition()

        self.jungChatLogger.HoldToAnswerViewWidthAnchor.constant = 0
        self.jungChatLogger.layoutIfNeeded()


        let actions: [KindActionType] = [.deactivate]
        let actionViews: [ActionViewName] = [.HudView]
        let routine = self.talkbox.routineFromText(dialog: SelfieCheckMSG.wait.rawValue, action: actions, actionView: actionViews, options: nil)

        self.talkbox.displayRoutine(routine: routine)

        jungAWSRekognition.sendImageToRekognition(imageData: badgeSelfieImage, completion: { (result) in
            delay(bySeconds: 1, closure: {


                if result != .good {
                    self.talkbox.displayRoutine(routine: self.talkbox.routineFromText(dialog: result.rawValue, action: [.none], actionView: [.none], options:nil))

                } else {

                    self.hudView.userPictureImageVIew.image = image
                    self.talkbox.displayRoutine(routine: self.talkbox.routineFromText(dialog: result.rawValue, action: [.none], actionView: [.none], options: nil))


                    let txt = "Let me show how you look like.-Look up ☝️."
                    let actions: [KindActionType] = [.none, .activate]
                    let actionViews: [ActionViewName] = [.none,.HudView]

                    // TODO: all should look like this one.
                    let options = self.talkbox.createUserOptions(opt1: "Take another", opt2: "Keep this one", actionViews: (.BadgePhotoSetupView,.BadgePhotoSetupView))


                    self.talkbox.displayRoutine(routine: self.talkbox.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options), wait: 1)


                }
            })

        })
        }
    
    
    
}
