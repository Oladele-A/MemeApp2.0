//
//  SharedMemeViewController.swift
//  memeMe1.0
//
//  Created by Oladele Abimbola on 4/25/22.
//

import Foundation
import UIKit

class SharedMemeViewController: UIViewController{
    var meme : Meme!
    @IBOutlet weak var sharedMeme: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sharedMeme!.image = meme.memedImage
    }
}
