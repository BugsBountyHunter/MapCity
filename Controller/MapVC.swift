//
//  ViewController.swift
//  MapCity
//
//  Created by AHMED SR on 10/2/18.
//  Copyright © 2018 AHMED SR. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController , UIGestureRecognizerDelegate{
    //MARK:Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullupViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pullUpView: UIView!
    //Variable
    var locationManager = CLLocationManager()
    let authorizatoinStatus = CLLocationManager.authorizationStatus()
    var regionRaduis:Double = 1000
    
    var spinner:UIActivityIndicatorView?
    var progressLbl:UILabel?
    
    var screenSize = UIScreen.main.bounds
    
    
    //CollectionView
    var collectionView:UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocation()
        addDoubleTap()
       
    }
    //MARK:Functions
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
        //CollectionView Propertise
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        pullUpView.addSubview(collectionView!)
    }
    func animatedViewUp(){
        pullupViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animatedViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    //ADD AND REMOVE SPINNER
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2 ) - ( (spinner?.frame.width)! / 2 ), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    func removeSpinner(){
        if spinner != nil {
            spinner?.stopAnimating()
            spinner?.removeFromSuperview()
        }
    }
    
    //ADD AND REMOVE PRGRESSLBL
    func addPrgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2 ) - 120 , y: 170, width: 240, height: 40)
        progressLbl?.text = "12/40 PHOTO LOAD..."
        progressLbl?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        progressLbl?.font = UIFont (name: "Avenir Next", size: 18)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    func removeProgressLbl(){
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }

    //MARK:Action
    @IBAction func currentPlaceWasPressed(_ sender: Any) {
        if authorizatoinStatus == .authorizedAlways || authorizatoinStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    //MARK:@objc
    @objc func animatedViewDown(){
       pullupViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
        }
    }
    
}
//MARK:extension
extension MapVC:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    func centerMapOnUserLocation(){
       // guard let coordinateLati = locationManager.location?.coordinate.latitude else {return}
        guard let coordinate = locationManager.location?.coordinate else {return}
        print(coordinate as Any)
       
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRaduis * 2.0, longitudinalMeters: regionRaduis * 2.0 )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender:UITapGestureRecognizer){
        removePin()
        animatedViewUp()
        
        removeSpinner()
        removeProgressLbl()
        
        addSwipe()
        
        addSpinner()
        addPrgressLbl()
        let touchPoint = sender.location(in: mapView)
        let coordinatePoint = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(coordinatePoint as Any)
        let Annotation = DroppablePoint(coordinate: coordinatePoint, identefire: "droppablePin")
        mapView.addAnnotation(Annotation)
        print(DataService.instanc.flickrURL(forApiKey: API_KEY, withAnnotation: Annotation, andNumberOfPhoto: 40))
        DataService.instanc.retriveURLS(forAnnotation: Annotation) { (true,photoUrlArray) in
            //
            print(photoUrlArray)
        }
        let coordinateRegion = MKCoordinateRegion(center: coordinatePoint, latitudinalMeters: regionRaduis * 2.0 , longitudinalMeters: regionRaduis * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //Remove pre-pins
    func removePin(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}
extension MapVC:CLLocationManagerDelegate{
    func configureLocation(){
        if authorizatoinStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC:UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        
        return cell
    }
}
