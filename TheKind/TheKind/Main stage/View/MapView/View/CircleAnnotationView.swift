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

    let MAXSCIRCLESCALE: CGFloat = 6.0
    
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
        alpha = 0.9
    }
    
    override func prepareForReuse() {
        circleDetails = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.backgroundColor = DARKPINKCOLOR.cgColor
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Didn't use this because we can't get a completion out of it to time the other animations.
        
        // draft
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
        guard let location = circleAnnotationSet.location else {fatalError("circle can't have nil coordinates:  init(circleAnnotationSet: CircleAnnotationSet")}
        coordinate = location
        //title = circleAnnotationSet.circlePlotName
        circleDetails = circleAnnotationSet
        
    }
    
    
    override init() {
        super.init()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
