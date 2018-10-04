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
    static var progressLbl:UILabel?
    
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
        
        //CollectionView Propertise
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(collectionView!)
       
        registerForPreviewing(with: self, sourceView: collectionView!)
    }
    //MARK:Functions
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
   
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
        MapVC.progressLbl = UILabel()
        MapVC.progressLbl?.frame = CGRect(x: (screenSize.width / 2 ) - 120 , y: 170, width: 240, height: 40)
        MapVC.progressLbl?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        MapVC.progressLbl?.font = UIFont (name: "Avenir Next", size: 14)
        MapVC.progressLbl?.textAlignment = .center
        collectionView?.addSubview(MapVC.progressLbl!)
    }
    func removeProgressLbl(){
        if MapVC.progressLbl != nil {
            MapVC.progressLbl?.removeFromSuperview()
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
       DataService.instanc.cancelAllSession()
        DataService.instanc.imageArray = []
        collectionView?.reloadData()
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
        DataService.instanc.cancelAllSession()
        DataService.instanc.imageURLArray = []
        DataService.instanc.imageArray = []
        collectionView?.reloadData()
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

        let coordinateRegion = MKCoordinateRegion(center: coordinatePoint, latitudinalMeters: regionRaduis * 2.0 , longitudinalMeters: regionRaduis * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        DataService.instanc.retriveURLS(forAnnotation: Annotation) { (success) in
            if success{
                DataService.instanc.retriveImage(handler: { (finished) in
                    if finished{
                    self.removeSpinner()
                    self.removeProgressLbl()
                
                    self.collectionView?.reloadData()
                
                    }
                })
            }
        }
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
        return DataService.instanc.imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let indexArray = DataService.instanc.imageArray[indexPath.item]
        let image = UIImageView(image: indexArray)
        cell.addSubview(image)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {
            return
        }
        let imagepasssed = DataService.instanc.imageArray[indexPath.row]
        popVC.initData(forImage: imagepasssed)
        present(popVC, animated: true, completion: nil)
    }
}
extension MapVC:UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) , let cell = collectionView?.cellForItem(at: indexPath) else{return nil }
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else{return nil }
        
        popVC.initData(forImage: DataService.instanc.imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        
        return popVC
        
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
