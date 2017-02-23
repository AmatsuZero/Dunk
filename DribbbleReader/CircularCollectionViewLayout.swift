//
//  CircularCollectionViewLayout.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/22.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    // 1.需要anchorPoint，是因为旋转不是围绕着每个item的中心点转的
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    var angle: CGFloat = 0 {
        // 2.当angle参数设置时，就立即令其transform等于angle的角度，而zIndex则是使得后一个item覆盖前一个item，从而实现右边的item覆盖在左边的item的效果。
        didSet {
            zIndex = Int(angle * 1000000)
            transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    //3.覆盖copyWithZone()，是因为当collection view实施layout时会copy参数，覆盖这个method确保anchorPoint和angle会被copy
    override func copy(with zone: NSZone? = nil) -> Any {
        let copiedAttributes: CircularCollectionViewLayoutAttributes =
            super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
}

class CircularCollectionViewLayout: UICollectionViewLayout {
    
    let itemSize = CGSize(width: 133, height: 173)
    var attributesList = [CircularCollectionViewLayoutAttributes]()
    
    var radius: CGFloat = 500 {
        didSet {
            //当半径radius变化的时候就重新设置Layout利用didSet里的invalidateLayout()
            invalidateLayout()
        }
    }
    var anglePerItem: CGFloat {
        return atan(itemSize.width / radius)
    }
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ?
            -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
    }
    
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize.width -
            collectionView!.bounds.width)
    }
    
    override class var layoutAttributesClass: AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        
        let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
        // 1.用tan的反函数求出theta
        let theta = atan2(collectionView!.bounds.width / 2.0,
                          radius + (itemSize.height / 2.0) - (collectionView!.bounds.height / 2.0))
        // 2.初始化startIndex和endIndex为0和最后一个
        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
        // 3.如果angle小于-theta，则代表其不在屏幕上。那么出现在屏幕的第一个item
        //的index则为angle至-θ的角度除以anglePerItem，因为angle为负值，所以就先变为正值。向下取整则代表item要完全不在屏幕才消失
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        // 4.同样，最后的item的idex则为angle加上θ除以anglePerItem，然后使用min确保不会超出范围
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
        // 5.最后的会发生滑动过快，从而使所有的item消失在屏幕。
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        
        let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width / 2.0)
        attributesList = (startIndex..<collectionView!.numberOfItems(inSection: 0)).map { (i)
            -> CircularCollectionViewLayoutAttributes in
            // 1.创建每个idexPath的CircularCollectionViewLayoutAttributes对象，并且设置size
            let attributes = CircularCollectionViewLayoutAttributes(forCellWith: NSIndexPath(item: i, section: 0) as IndexPath)
            attributes.size = self.itemSize
            // 2.将每个item的位置都设置为屏幕中心
            attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
            // 3.将每个item都旋转(anglePerItem * i)度
            attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            return attributes
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width,
                      height: collectionView!.bounds.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        
        //1. 计算出将要停下的角度proposedAngle，和比率ratio
        let factor = -angleAtExtreme/(collectionViewContentSize.width -
            collectionView!.bounds.width)
        let proposedAngle = proposedContentOffset.x*factor
        
        let ratio = proposedAngle/anglePerItem
        var multiplier: CGFloat
        //2.接着将比率ratio取整
        if (velocity.x > 0) {
            multiplier = ceil(ratio)
        } else if (velocity.x < 0) {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        //3.再用整数的比率求出最终的ContentOffset
        finalContentOffset.x = multiplier*anglePerItem/factor
        return finalContentOffset
    }
}
