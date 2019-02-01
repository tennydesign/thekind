//
//  CarouselView.swift
//  TheKind
//
//  Created by Tenny on 1/31/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit
import iCarousel

class CarouselView: UIView,iCarouselDataSource, iCarouselDelegate {
  
    @IBOutlet var carousel: iCarousel!
    
    var items: [Int] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0 ... 3 {
            items.append(i)
        }
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .cylinder
    
    }
    
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }

    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 138, height: 90))
            itemView.image = UIImage(named: "hud_kind_icon")
            itemView.contentMode = .scaleAspectFit
            
            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.font = label.font.withSize(50)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        //label.text = "\(items[index])"
        
        return itemView
        
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
//    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
////        let distance: CGFloat = 100 //number of pixels to move the items away from camera
////        let spacing: CGFloat = 0.5
////        let clampedOffset: CGFloat = min(1.0,max(-1.0,offset))
////
////        let z: CGFloat = -abs(clampedOffset) * distance
////        let newoffset = offset + clampedOffset * spacing
////        return CATransform3DTranslate(transform, newoffset * carousel.itemWidth, 0.0, z)
//    }
    

    
    @IBOutlet var mainView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CarouselView", owner: self, options: nil)
        addSubview(mainView)
        

    }
    
    
    
}
