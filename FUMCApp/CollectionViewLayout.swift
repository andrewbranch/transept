//
//  CollectionViewLayout.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit


class CollectionViewLayout: UICollectionViewLayout {
    
    let itemInsets: UIEdgeInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
    var itemSize: CGSize = CGSizeMake(200.0, 200.0)
    let interItemSpacingY: CGFloat = 30.0
    let numberOfColumns: NSInteger = 1
    let sectionInsets: UIEdgeInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
    
    var cellId: NSString?
    var layoutInfo: NSDictionary?
    var cellsAppeared = false
    
    private let mediaCellId = "MediaCell"
    private let connectCellId = "ConnectCell"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareLayout() {
        var newLayoutInfo = NSMutableDictionary()
        var cellLayoutInfo = NSMutableDictionary()
        
        var sectionCount = self.collectionView!.numberOfSections()
        var indexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        self.itemSize.width = self.collectionViewContentSize().width / CGFloat(self.numberOfColumns)
        
        for (var section = 0; section < sectionCount; section++) {
            var itemCount = self.collectionView!.numberOfItemsInSection(section)
            for (var item = 0; item < itemCount; item++) {
                indexPath = NSIndexPath(forItem: item, inSection: section)
                
                var itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                itemAttributes.frame = self.frameForCell(atIndexPath: indexPath)
                
                cellLayoutInfo[indexPath] = itemAttributes
            }
        }
        
        newLayoutInfo[mediaCellId] = cellLayoutInfo
        newLayoutInfo[connectCellId] = cellLayoutInfo
        self.layoutInfo = newLayoutInfo
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: itemIndexPath)
        var frame = self.frameForCell(atIndexPath: itemIndexPath)
        itemAttributes.center = CGPointMake(frame.midX, frame.midY)
        return itemAttributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var allAttributes = NSMutableArray(capacity: self.layoutInfo!.count)
        
        self.layoutInfo!.enumerateKeysAndObjectsUsingBlock({ (layoutKey, cellLayoutDictionary, stop) -> Void in
            cellLayoutDictionary.enumerateKeysAndObjectsUsingBlock({ (indexPath, attributes, innerStop) -> Void in
                if (CGRectIntersectsRect(rect, attributes.frame)) {
                    allAttributes.addObject(attributes)
                }
            })
        })
        
        return allAttributes;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.layoutInfo![mediaCellId]![indexPath] as UICollectionViewLayoutAttributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        var rowCount = self.collectionView!.numberOfItemsInSection(0) / self.numberOfColumns
        if (self.collectionView!.numberOfSections() % self.numberOfColumns > 0) { rowCount++ }
        
        var height = self.itemInsets.top + CGFloat(rowCount) * self.itemSize.height + CGFloat(rowCount - 1) * self.interItemSpacingY + self.itemInsets.bottom + self.sectionInsets.top + self.sectionInsets.bottom
        
        return CGSizeMake(self.collectionView!.bounds.size.width, height)
    }
    
    func frameForCell(atIndexPath indexPath: NSIndexPath) -> CGRect {
        let row = indexPath.item / self.numberOfColumns
        let column = indexPath.item % self.numberOfColumns
        let columnWidth = self.collectionViewContentSize().width / CGFloat(self.numberOfColumns);
        
        var spacingX = self.collectionView!.bounds.size.width - self.itemInsets.left - self.itemInsets.right - CGFloat(self.numberOfColumns) * self.itemSize.width
        if (self.numberOfColumns > 1) { spacingX /= CGFloat(self.numberOfColumns - 1) }
        
        var originX = floor(self.itemInsets.left + (self.itemSize.width + spacingX) * CGFloat(column)) + (columnWidth - self.itemSize.width - self.itemInsets.left - self.itemInsets.right) / 2.0
        var originY = floor(self.itemInsets.top + (self.itemSize.height + self.interItemSpacingY) * CGFloat(row)) + self.sectionInsets.top
        
        return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height)
    }
   
}
