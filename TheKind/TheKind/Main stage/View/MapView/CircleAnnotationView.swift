//
//  CircleAnnotationView.swift
//  TheKind
//
//  Created by Tenny on 3/29/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import MapKit
import Mapbox

class CircleAnnotationView: MGLAnnotationView {
    
    var circleDetails: CircleAnnotationSet? {
        didSet {
            
        }
    }
    let button = UIButton(type: .system)
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    
    
    func commonInit() {
        alpha = 0.7
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.backgroundColor = UIColor(r: 176, g: 38, b: 65).cgColor
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        //        // Animate the border width in/out, creating an iris effect.
        //        let animation = CABasicAnimation(keyPath: "borderWidth")
        //        animation.duration = 0.4
        //        layer.borderWidth = selected ? bounds.width / 1 : 2
        //        layer.add(animation, forKey: "borderWidth")
        //
        
    }
    
}



class KindPointAnnotation: MGLPointAnnotation {
    var circleDetails: CircleAnnotationSet? {
        didSet {
            
        }
    }
    
    init(circleAnnotationSet: CircleAnnotationSet) {
        super.init()
        coordinate = circleAnnotationSet.location
        title = circleAnnotationSet.circlePlotName
        circleDetails = circleAnnotationSet
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
