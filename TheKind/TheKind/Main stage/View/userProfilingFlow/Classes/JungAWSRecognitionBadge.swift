//
//  AWSRecognitionBadge.swift
//  TheKind
//
//  Created by Tenny on 12/17/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation
import AWSRekognition

class JungAWSRekognition{
    
    var rekognitionObject:AWSRekognition?
    
    func sendImageToRekognition(imageData: Data, completion: @escaping (SelfieCheckMSG)->()) {
        
        
        rekognitionObject = AWSRekognition.default()
        let imageAWS = AWSRekognitionImage()
        imageAWS?.bytes = imageData
        
        let request = AWSRekognitionDetectFacesRequest()
        request?.image = imageAWS
        var analyzeResult: SelfieCheckMSG?
        
        rekognitionObject?.detectFaces(request!) { (result, err) in
            if let err = err {
                print(err)
                return
            }
            print(result?.faceDetails?.count ?? 0)
            print(result?.faceDetails ?? "")
            if let faceDetails = result?.faceDetails {
                
                if faceDetails.count == 0 {
                    analyzeResult = .noface
                } else if faceDetails.count > 1 {
                        analyzeResult = .group
                } else if faceDetails.first?.boundingBox?.height?.doubleValue ?? 0 < 0.4 {
                        analyzeResult = .far
                } else if faceDetails.first?.quality?.brightness?.doubleValue ?? 0 < 25 {
                        analyzeResult = .dark
                } else if (faceDetails.first?.landmarks?.first?.x?.doubleValue ?? 0 > 0.6) ||
                    (faceDetails.first?.landmarks?.first?.y?.doubleValue ?? 0 > 0.6) ||
                    (faceDetails.first?.landmarks?.first?.y?.doubleValue ?? 0 < 0.1)
                    
                {
                    analyzeResult = .offcenter
                } else {
                    // all good.
                    analyzeResult = .good
                }
            }
            completion(analyzeResult ?? .nogood)
        }
        
       
    }

    
}

enum SelfieCheckMSG: String {
    case noface = "I can't see you. Is it just me?",
    group = "Group selfies are great but please take this one solo.-Sometimes I get confused and see more people.- Pardon my dusted eye." ,
    far = "I see you... but you seem too far. Get closer to the camera.",
    dark = "Wow... it's dark out there. Turn on the lights and try again.",
    offcenter = "Ops... Something is wrong. I can only see half of you.",
    good = "I loved it!",
    nogood = "For some reason this one is not good. Please try again",
    wait = "Let me take a look at it. It may take me a couple of seconds."
}

