//
//  QuickLookCollectionViewCell.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/20.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import MBProgressHUD

class QuickLookCollectionViewCell: UICollectionViewCell, MBProgressHUDDelegate {
    
    var imageView: UIImageView! = UIImageView()
    var shotName: UILabel! = UILabel()
    var designerName: UILabel! = UILabel()
    var designerIcon: UIImageView! = UIImageView()
    var viewLabel: UILabel! = UILabel()
    var viewUnitLabel:UILabel! = UILabel()
    var segmentView: UIView! = UIView()
    var downSideView:UIView! = UIView()

    required init?(coder aDecoder: NSCoder) {
        //必须
        super.init(coder:aDecoder)
    }

    //必须要实现
    override init(frame: CGRect) {
        super.init(frame: frame)
        //设置子视图
        self.setUpSubViews()
    }

    func setUpSubViews() {
        
        //在设置依赖的时候，一定要确保依赖的视图已经添加
        self.contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.lessThanOrEqualTo(self.bounds.height - 51)
        }
        
        self.contentView.addSubview(segmentView)
        segmentView.backgroundColor = UIColor.black
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(0)
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        self.contentView.addSubview(downSideView)
        downSideView.backgroundColor = UIColor.white
        downSideView.snp.makeConstraints { (make)  in
            make.top.equalTo(segmentView.snp.bottom)
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }

        downSideView.addSubview(designerIcon)
        designerIcon.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.left.equalTo(downSideView.snp.left).offset(8)
        }

        downSideView.addSubview(shotName)
        shotName.font = UIFont.italicSystemFont(ofSize: 13)
        shotName.textColor = UIColor.cellLabelColor()
        shotName.snp.makeConstraints { (make) in
            make.left.equalTo(designerIcon.snp.right).offset(17)
            make.centerY.equalToSuperview().offset(10)
            make.width.lessThanOrEqualTo(180)
        }
        
        downSideView.addSubview(designerName)
        designerName.font = UIFont.init(name: "Verdana", size: 12)
        designerName.textColor = UIColor.cellLabelColor()
        designerName.snp.makeConstraints { (make) in
            make.left.equalTo(designerIcon.snp.right).offset(17)
            make.centerY.equalToSuperview().offset(-11.5)
        }

        downSideView.addSubview(viewUnitLabel)
        viewUnitLabel.font = UIFont.init(name: "Verdana", size: 12)
        viewUnitLabel.textColor = UIColor.cellLabelColor()
        viewUnitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-4)
        }

        downSideView.addSubview(viewLabel)
        viewLabel.font = UIFont.init(name: "Verdana", size: 17)
        viewLabel.textColor = UIColor.cellLabelColor()
        viewLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-48)
            make.bottom.equalTo(viewUnitLabel.snp.bottom).offset(1)
        }
    }
    
    func setContent(shot: Shot)  {
        
        //创建进度HUD
        let bigImgHUD = MBProgressHUD.showAdded(to: imageView, animated: true)
        bigImgHUD.bezelView.color = UIColor.clear
        bigImgHUD.label.text = "Loading..."
        bigImgHUD.backgroundView.style = .blur
        bigImgHUD.delegate = self
        
        //这是SDWebImage与Swift不兼容的有一大罪恶，Bug至今未修复：http://stackoverflow.com/questions/38949214/ambiguous-use-of-sd-setimagewithplaceholderimagecompleted-with-swift-3
        
        //创建透明色占位图
        let placeHolderImage = UIColor.clear.convertToImage(rect: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
        imageView.sd_setImage(with: URL(string: shot.imageUrl), placeholderImage: placeHolderImage!, options: SDWebImageOptions.retryFailed) { (image, error, type, url) in
            DispatchQueue.main.async {
                bigImgHUD.hide(animated: true)
            }
        }
        
        designerIcon.sd_setImage(with: URL(string: shot.avatarUrl), placeholderImage: UIImage(named: "comment_profile_mars"), options: SDWebImageOptions.retryFailed) { (image, error, type, url) in
    
        }
        
        designerIcon.dj_addCorner(radius: designerIcon.bounds.width / 2)
        shotName.text = shot.shotName
        designerName.text = shot.designerName
        viewLabel.text = String(shot.shotCount)
      
        viewUnitLabel.text = "Views"
        
        //这一步一定要在最后做，确保遮罩在最上面
        self.contentView.dj_addCorner(radius: 3)
    }
    
    func hudWasHidden(_ hud: MBProgressHUD) {
        if !hud.isHidden {
            //MBProgreHUD有相当高的概率移除失败，这里判断一下，如果没有隐藏，用MBProgressHUD提供的类方法隐藏一下
            MBProgressHUD.hide(for: imageView, animated: true)
        }
    }
}
