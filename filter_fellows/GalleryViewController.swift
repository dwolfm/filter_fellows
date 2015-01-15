//
//  GalleryViewController.swift
//  filter_fellows
//
//  Created by nacnud on 1/12/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

import UIKit

protocol ImageSelectedProtocol {
    func controllerDidSelectImage(UIImage) -> Void
}


class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    var images : [UIImage] = []
    var delegate: ImageSelectedProtocol?
    
    
    
    
    override func loadView() {
        let rootView = UIView(frame: UIScreen.mainScreen().bounds)
        
        //MARK: setup CollectionView
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
        rootView.addSubview(self.collectionView)
        collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.collectionView.registerClass(GalleryCell.self , forCellWithReuseIdentifier: "GALLERY_CELL")
        
        images.append(UIImage(named: "a")!)
        images.append(UIImage(named: "b")!)
        images.append(UIImage(named: "c")!)
        images.append(UIImage(named: "d")!)
        images.append(UIImage(named: "e")!)
        images.append(UIImage(named: "f")!)
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.imageView.image = self.images[indexPath.row]
        return cell
        
    }
    
    //MARK:  did select row index path
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.controllerDidSelectImage(self.images[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
