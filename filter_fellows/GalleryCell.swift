//
//  GalleryCell.swift
//  filter_fellows
//
//  Created by nacnud on 1/12/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame )
        self.addSubview(self.imageView)
        self.backgroundColor = UIColor.whiteColor()
        self.imageView.frame = self.bounds
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.layer.masksToBounds = true
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
