//
//  ViewController.swift
//  filter_fellows
//
//  Created by nacnud on 1/12/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let alertController = UIAlertController(title:"whats your choise", message: "red pill or blue pill", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let mainImageView = UIImageView()
    var collectionView: UICollectionView!
    var collectionViewYConstraint : NSLayoutConstraint!
    var originalThumbnail :UIImage!
    var filterNames : [String] = []
    let imageQueue = NSOperationQueue()
    var gpuContext: CIContext!
    var thumbnails: [Thumbnail] = []
    var doneButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    override func loadView() {
        let rootView = UIView(frame: UIScreen.mainScreen().bounds)
        rootView.backgroundColor = UIColor.whiteColor()
        //MARK: setup views
        //MARK: setup photobutton
        let photoButton = UIButton()
        photoButton.setImage(UIImage(named: "photoButton"), forState: .Normal)
        photoButton.imageView?.contentMode = UIViewContentMode.ScaleToFill
        photoButton.addTarget(self, action: "photoButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        rootView.addSubview(photoButton)
        
        //MARK: setup main ImageView
        self.mainImageView.backgroundColor = UIColor.blackColor()
        rootView.addSubview(self.mainImageView)
        
        //MARK: setup collectionView
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
        collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 100)
        collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        rootView.addSubview(self.collectionView)
        self.collectionView.dataSource = self
        self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
        
        //MARK: setup views for autolayout
        let views = ["photoButton": photoButton, "mainImageView": self.mainImageView, "collectionView": self.collectionView]
        for (key, view) in views{
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        setupConstraintsOnRootView(rootView, forViews: views)
        
        // load root view last
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: add actions to UIAlertView
        let galleryOption = UIAlertAction(title: "blue pill", style: UIAlertActionStyle.Default) { (action) -> Void in
            let galleryVC = GalleryViewController()
            galleryVC.delegate = self
            self.navigationController?.pushViewController(galleryVC, animated: true)
        }
        let filterOption = UIAlertAction(title: "red pill", style: UIAlertActionStyle.Default) { (action) -> Void in
            println("clicked filter action")
            self.collectionViewYConstraint.constant = 20
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.view.setNeedsLayout()
                
            })
        }
        self.alertController.addAction(galleryOption)
        self.alertController.addAction(filterOption)
        
        // Setup Navigation bar buttons
        self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")
        self.navigationItem.rightBarButtonItem = self.shareButton
        
        // Setup UIImagePickerController
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraOption = UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            })
            self.alertController.addAction(cameraOption)
        }
        
        
        // setup gpu context for making thumbnails
        let options = [kCIContextWorkingColorSpace : NSNull()]
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
        self.setupThumbnails()
        
    }//end viewdidload
    
    //MARK: setupTHumbails()
    func setupThumbnails(){
        self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir"]
        for name in self.filterNames {
            let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
            self.thumbnails.append(thumbnail)
        }
    }
    
    //MARK: genorate thumbnails
    func generateThumbnail(originalImage: UIImage){
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    //MARK: button Selectors
    func photoButtonPressed(){
        println("photo buttun pressed :)")
        self.presentViewController(self.alertController, animated: true, completion: nil)
    }
    
    func donePressed(){
        println("done selected")
    }
    
    func sharePressed(){
        println("share pressed")
    }
    
    //MARK: conform to ImageSelectedProtocol
    func controllerDidSelectImage(image: UIImage) {
        self.mainImageView.image = image
        println("booya imageViewd be set")
        self.generateThumbnail(image)
        for thumbnail in self.thumbnails {
            thumbnail.originalImage = self.originalThumbnail
        }
        self.collectionView.reloadData()
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnails.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
        let thumbnail = self.thumbnails[indexPath.row]
        if thumbnail.originalImage != nil {
            if thumbnail.filteredImage == nil {
                thumbnail.generateFilteredImage()
                cell.imageView.image = thumbnail.filteredImage!
                
            }
        }
        return cell
    }
    
    
    
    //Mark: set autolayout constraints
    func setupConstraintsOnRootView(rootView: UIView, forViews views: [String:AnyObject]){
        // photobutton constraits
        let photoButton = views["photoButton"] as UIView!
        let photoButtonVerticalConstraint = NSLayoutConstraint(item: photoButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -20)
        let photoButtonHorizontalConstraint = NSLayoutConstraint(item: photoButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        rootView.addConstraint(photoButtonHorizontalConstraint)
        rootView.addConstraint(photoButtonVerticalConstraint)
        
        // mainImageView constraitns
        let mainImageViewVerticleContstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImageView]-30-[photoButton]|", options: nil, metrics: nil, views: views)
        let mainImageViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImageView]-|", options: nil, metrics: nil, views: views)
        rootView.addConstraints(mainImageViewVerticleContstraints)
        rootView.addConstraints(mainImageViewHorizontalConstraints)
        
        // collectionview constraints
        let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
        rootView.addConstraints(collectionViewConstraintsHorizontal)
        let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
        self.collectionView.addConstraints(collectionViewConstraintHeight)
        let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
        rootView.addConstraints(collectionViewConstraintVertical)
        self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint
        
    }
    
}

