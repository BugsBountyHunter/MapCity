//
//  DroppablePin.swift
//  MapCity
//
//  Created by AHMED SR on 10/3/18.
//  Copyright © 2018 AHMED SR. All rights reserved.
//

import UIKit
import MapKit

class DroppablePoint : NSObject , MKAnnotation {
     dynamic var coordinate:CLLocationCoordinate2D
     var identifire:String
    
    init(coordinate:CLLocationCoordinate2D , identefire:String) {
        self.coordinate = coordinate
        self.identifire = identefire
        super.init()
    }
}
