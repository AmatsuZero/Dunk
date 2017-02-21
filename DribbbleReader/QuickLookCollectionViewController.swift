//
//  QuickLookCollectionViewController.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/21.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit

private let reuseIdentifier = "QucikLookCollectionViewCell"

class QuickLookCollectionViewController: UICollectionViewController, UIViewControllerPreviewingDelegate {

    fileprivate var shots:[Shot] = [Shot]() {
        didSet { self.collectionView?.reloadData() }
    }

    fileprivate var cellWidth:CGFloat = 0.0
    fileprivate var cellHeight:CGFloat = 0.0

    fileprivate let cellVerticalMargin:CGFloat = 20.0
    fileprivate let cellHorizontalMargin:CGFloat = 20.0

    var API_URL = Config.SHOT_URL

    var shotPages = 1

    required init?(coder aDecoder: NSCoder) {
        //必须
        super.init(coder:aDecoder)
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
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

        cellWidth = self.view.bounds.width
        cellHeight = self.view.bounds.height / 2.5

        DribbleObjectHandler.getShots(API_URL, callback: {(shots) -> Void in
            self.shots = shots
        })

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(QuickLookCollectionViewController.refreshInvoked(_:)), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
    }

    func refreshInvoked(_ sender:AnyObject) {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QuickLookCollectionViewCell

        let shot = shots[indexPath.row]

        cell.setContent(shot: shot)

        if shots.count - 1 == indexPath.row && shotPages < 5 {
            shotPages += 1
            print(shotPages)
            let url = API_URL + "&page=" + String(shotPages)
            DribbleObjectHandler.getShots(url, callback: {(shots) -> Void in

                for shot in shots {
                    self.shots.append(shot)
                }
            })
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth - cellHorizontalMargin, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return cellVerticalMargin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QuickLookCollectionViewCell
        let shot = shots[indexPath.row]
        let vc = self.prepareForDisplay(shot)
        parent?.present(vc, animated: true, completion: nil)
    }
    
    func prepareForDisplay(_ shot: Shot) -> ImageModalViewController {
        let vc = ImageModalViewController(nibName: "ImageModalViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.pageUrl = shot.htmlUrl
        vc.shotName = shot.shotName
        vc.designerName = shot.designerName
        let downloadQueue = DispatchQueue(label: "com.naoyashiga.processdownload", attributes: [])
        downloadQueue.async {
            let data = try? Data(contentsOf: URL(string: shot.imageUrl)!)
            var image: UIImage?
            if data != nil {
                shot.imageData = data
                image = UIImage(data: data!)!
            }
            DispatchQueue.main.async {
                vc.imageView.image = image
            }
        }
        return vc
    }

    // MARK: Peep&Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let index = collectionView?.indexPathForItem(at: location)
        guard (collectionView?.cellForItem(at: index!)) != nil else {
            return nil
        }
        let shot = shots[(index?.row)!]
        return prepareForDisplay(shot)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
       show(viewControllerToCommit, sender: self)
    }
}
