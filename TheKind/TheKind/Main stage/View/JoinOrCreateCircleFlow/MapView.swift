//
//  MapView.swift
//  TheKind
//
//  Created by Tenny on 1/18/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import Mapbox
import MapKit

class MapView: KindActionTriggerView, MGLMapViewDelegate {
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet var mainView: UIView!
    var locationManager: CLLocationManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        locationManager = CLLocationManager()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MapView", owner: self, options: nil)
        addSubview(mainView)
        
        let style = "mapbox://styles/tennydesign/cjr2x6f1318ey2sml5xk2itrb"
        mapView.styleURL = URL(string:style)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let coordinate = locationManager?.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        } else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: 45.52954,
                                                     longitude: -122.72317),
                              zoomLevel: 14, animated: false)
        }

        self.talkbox?.delegate = self
    }
    
    override func activate() {
        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        UIView.animate(withDuration: 1) {
            self.alpha = 1
        }
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
}
