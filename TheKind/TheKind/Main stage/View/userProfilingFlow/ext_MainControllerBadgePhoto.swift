//
//  ext_MainControllerBadgePhoto.swift
//  TheKind
//
//  Created by Tenny on 12/24/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func hitPickerControl() {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        //pickerController.cameraOverlayView = OVERLAY!!
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        pickerController.delegate = self
        pickerController.cameraDevice = .front
        present(pickerController, animated: true)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        jungChatLogger.resetAnswerViewWidthAnchor() //0
        //jungChatLogger.resetJungChat()
        dismiss(animated: true)
    }
    

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        dismiss(animated: true)

        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }

        let badgeSelfieImage:Data = image.jpegData(compressionQuality: 0.2)!

        let jungAWSRekognition = JungAWSRekognition()

        //self.jungChatLogger.HoldToAnswerViewWidthAnchor.constant = 0
        jungChatLogger.resetAnswerViewWidthAnchor() //0
        //jungChatLogger.resetJungChat()
        //self.talkbox.clearJungChat()

        let actions: [KindActionType] = [.deactivate]
        let actionViews: [ActionViewName] = [.HudView]
        let routine = self.talkbox.routineFromText(dialog: SelfieCheckMSG.wait.rawValue, actions: actions, actionViews: actionViews, options: nil)

        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox.kindExplanationPublisher.onNext(rm)
        }
        

        jungAWSRekognition.sendImageToRekognition(imageData: badgeSelfieImage, completion: { (result) in
            delay(bySeconds: 1, closure: {


                if result != .good {
                    let routine = self.talkbox.routineFromText(dialog: result.rawValue, actions: [.none], actionViews: [.none], options:nil)
                    if let routine = routine {
                        let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
                        self.talkbox.kindExplanationPublisher.onNext(rm)
                    }

                } else {

                    self.hudView.userPictureImageVIew.image = image

                    let txt = result.rawValue + "-Let me show how you look like.-Look up ☝️."
                    let actions: [KindActionType] = [.none, .none, .talk]
                    let actionViews: [ActionViewName] = [.none, .none,.HudView]

                    // TODO: all should look like this one.
                    let options = self.talkbox.createUserOptions(opt1: "Take another", opt2: "Keep this one", actionViews: (.BadgePhotoSetupView,.BadgePhotoSetupView))

                    let routine = self.talkbox.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
                 

                    if let routine = routine {
                        let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
                        self.talkbox.kindExplanationPublisher.onNext(rm)
                    }


                }
            })

        })
        }
    
    
    
}
