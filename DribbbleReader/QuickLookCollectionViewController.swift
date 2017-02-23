//
//  QuickLookCollectionViewController.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/21.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit
import MBProgressHUD

private let reuseIdentifier = "QucikLookCollectionViewCell"

class QuickLookCollectionViewController: UICollectionViewController, UIViewControllerPreviewingDelegate, MBProgressHUDDelegate {

    fileprivate var shots:[Shot] = [Shot]() {
        didSet {
            self.collectionView?.reloadData()
            loadingHUD?.hide(animated: true)
        }
    }

    fileprivate let cellWidth:CGFloat = UIScreen.main.bounds.width
    fileprivate let cellHeight:CGFloat = UIScreen.main.bounds.height / 2.5

    fileprivate let cellVerticalMargin:CGFloat = 20.0
    fileprivate let cellHorizontalMargin:CGFloat = 20.0

    var API_URL = Config.SHOT_URL

    var shotPages = 1
    
    var currentImg: UIImage?
    
    var loadingHUD: MBProgressHUD?

    required init?(coder aDecoder: NSCoder) {
        //必须
        super.init(coder:aDecoder)
    }
    
    init() {
        let layout = CustomCollectionViewFlowLayout()
        //必须调用指定构造器
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
        self.collectionView!.register(QuickLookCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        //添加背景进度条
        loadingHUD = MBProgressHUD.showAdded(to: collectionView!, animated: true)
        loadingHUD?.bezelView.color = UIColor.clear
        loadingHUD?.mode = .indeterminate
        loadingHUD?.animationType = .fade
        loadingHUD?.label.text = "Loading...".getLocalizedString()
        loadingHUD?.backgroundView.style = .blur
        loadingHUD?.delegate = self
        
        loadingHUD?.show(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.once {
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == .available {
                    registerForPreviewing(with: self, sourceView: view)
                }
            }
        }
    }

    func loadShots(){
        self.collectionView!.backgroundColor = UIColor.hexStr("f5f5f5", alpha: 1.0)

        DribbleObjectHandler.getShots(API_URL, callback: {(shots) -> Void in
            self.shots = shots
        })

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(QuickLookCollectionViewController.refreshInvoked(_:)), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
    }

    func refreshInvoked(_ sender:AnyObject) {
        collectionView?.collectionViewLayout = CircularCollectionViewLayout()
        sender.beginRefreshing()
        collectionView?.reloadData()
        sender.endRefreshing()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return shots.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let shot = shots[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QuickLookCollectionViewCell
        cell.setContent(shot: shot)
        if shots.count - 1 == indexPath.row && shotPages < 5 {
           shotPages += 1
           let url = API_URL + "&page=" + String(shotPages)
           DribbleObjectHandler.getShots(url, callback: {(shots) -> Void in
                for shot in shots {
                    self.shots.append(shot)
                }
           })
        }
        return cell
    }
    
    func prepareForDisplay(_ shot: Shot, _ forPeek:Bool = false) -> LightLoomViewController {
        let vc = LightLoomViewController(fromPeek:forPeek)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.imageUrl = shot.imageUrl
        vc.pageUrl = shot.htmlUrl
        vc.shotName = shot.shotName
        vc.designerName = shot.designerName
        return vc
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        switch collectionViewLayout.self {
            default:
                return CGSize(width: cellWidth - cellHorizontalMargin, height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return cellVerticalMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch collectionViewLayout.self {
            case is CustomCollectionViewFlowLayout:
                return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            default:
                return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QuickLookCollectionViewCell
        let shot = shots[indexPath.row]
        let vc = self.prepareForDisplay(shot)
        parent?.present(vc, animated: true, completion: nil)
    }

    // MARK: Peep&Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let index = collectionView?.indexPathForItem(at: location)
        guard (collectionView?.cellForItem(at: index!)) != nil else {
            return nil
        }
        let shot = shots[(index?.row)!]
        let vc = prepareForDisplay(shot, true)
        currentImg = vc.imageView.image
        return vc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let vc = viewControllerToCommit as! LightLoomViewController
        let item = UIBarButtonItem.init(title: "Share".getLocalizedString(), style: .plain, target: self, action: #selector(share))
        vc.navigationItem.rightBarButtonItem = item
        show(vc, sender: self)
    }
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [currentImg!], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)

    }
}
