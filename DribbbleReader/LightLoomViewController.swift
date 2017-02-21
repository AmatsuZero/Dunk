//
//  LightLoomViewController.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/21.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class LightLoomViewController: UIViewController {
    var parentNavigationController = UINavigationController()
    var pageUrl = ""
    var shotName = ""
    var designerName = ""
    var isForPeek:Bool = false
    var imageView = UIImageView()
    var shareButton = UIButton.init()
    var imageUrl: String = "" {
        didSet {
            //创建透明色占位图
            let placeHolderImage = UIColor.red.convertToImage(rect: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
            imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: placeHolderImage, options: SDWebImageOptions.retryFailed) { (image, error, type, url) in
                
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        //必须
        super.init(coder:aDecoder)
    }
    
    required init(fromPeek: Bool) {
        super.init(nibName: nil, bundle: nil)
        isForPeek = fromPeek
        self.view.backgroundColor = UIColor.black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpConstraints()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideController(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func hideController(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    private func setUpConstraints() {
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(300)
        }
        
        if !isForPeek {
            shareButton.setTitle("Share Image", for: .normal)
            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            shareButton.addTarget(self, action: #selector(shareWithActivityControllerVC(_:)), for: .touchUpInside)
            self.view.addSubview(shareButton)
            shareButton.snp.makeConstraints { (make) in
                make.width.equalTo(87)
                make.height.equalTo(30)
                make.top.equalTo(imageView.snp.bottom).offset(57)
                make.right.equalToSuperview().offset(-20)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shareWithActivityControllerVC(_ sender: UIButton?) {
        let activityVC = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return [UIPreviewAction.init(title: "Share the Image", style: .default, handler: { (previewAction, peekController) in
            (peekController as? LightLoomViewController)?.shareWithActivityControllerVC(nil)
        })]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
