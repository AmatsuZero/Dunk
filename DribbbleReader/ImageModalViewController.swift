//
//  ImageModalViewController.swift
//  DribbbleReader
//
//  Created by naoyashiga on 2015/05/30.
//  Copyright (c) 2015年 naoyashiga. All rights reserved.
//

import UIKit
import Social

class ImageModalViewController: UIViewController {
    var parentNavigationController = UINavigationController()
    var pageUrl = ""
    var shotName = ""
    var designerName = ""

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func viewOriginalPageTapped(_ sender: UIButton) {
        shareWithActivityControllerVC(sender)
    }
    
    func shareWithActivityControllerVC(_ sender: UIButton?) {
        let activityVC = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return [UIPreviewAction.init(title: "Share the Image", style: .default, handler: { (previewAction, peekController) in
            (peekController as? ImageModalViewController)?.shareWithActivityControllerVC(nil)
        })]
    }
}
