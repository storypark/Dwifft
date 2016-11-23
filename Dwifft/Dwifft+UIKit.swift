//
//  TableViewDiffCalculator.swift
//  Dwifft
//
//  Created by Jack Flintermann on 3/13/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

#if os(iOS)

import UIKit

public class TableViewDiffCalculator<T: Equatable> {
    
    public weak var tableView: UITableView?
    
    public init(tableView: UITableView, initialRows: [T] = []) {
        self.tableView = tableView
        self._rows = initialRows
    }
    
    /// Right now this only works on a single section of a tableView. If your tableView has multiple sections, though, you can just use multiple TableViewDiffCalculators, one per section, and set this value appropriately on each one.
    public var sectionIndex: Int = 0
    
    /// You can change insertion/deletion animations like this! Fade works well. So does Top/Bottom. Left/Right/Middle are a little weird, but hey, do your thing.
    public var insertionAnimation = UITableViewRowAnimation.Automatic, deletionAnimation = UITableViewRowAnimation.Automatic
    
    /// Change this value to trigger animations on the table view.
    private var _rows: [T]
    public var rows : [T] {
        get {
            return _rows
        }
        set {
            let oldRows = rows
            let newRows = newValue
            let diff = oldRows.diff(newRows)
            if (diff.results.count > 0) {
                tableView?.beginUpdates()
                self._rows = newValue
                let insertionIndexPaths = diff.insertions.map({ NSIndexPath(forRow: $0.idx, inSection: self.sectionIndex) })
                let deletionIndexPaths = diff.deletions.map({ NSIndexPath(forRow: $0.idx, inSection: self.sectionIndex) })
                
                tableView?.insertRowsAtIndexPaths(insertionIndexPaths, withRowAnimation: insertionAnimation)
                tableView?.deleteRowsAtIndexPaths(deletionIndexPaths, withRowAnimation: deletionAnimation)
                tableView?.endUpdates()
            }
        }
    }
    
}

public class CollectionViewDiffCalculator<T: Equatable> {
    
    public weak var collectionView: UICollectionView?
    
    public init(collectionView: UICollectionView, initialRows: [T] = []) {
        self.collectionView = collectionView
        _rows = initialRows
    }
    
    /// Right now this only works on a single section of a collectionView. If your collectionView has multiple sections, though, you can just use multiple CollectionViewDiffCalculators, one per section, and set this value appropriately on each one.
    public var sectionIndex: Int = 0
    
    // Since UICollectionView (unlike UITableView) takes a block which must update its data source and trigger animations, we need to trigger the changes on set, instead of explicitly before and after set. This backing array lets us use a getter/setter in the exposed property.
    private var _rows: [T]
    
    /// Change this value to trigger animations on the collection view.
    public var rows : [T] {
        get {
            return _rows
        }
        set {
            let oldRows = rows
            let newRows = newValue
            let diff = oldRows.diff(newRows)
            if (diff.results.count > 0) {
                collectionView?.performBatchUpdates({ () -> Void in
                    self._rows = newValue
                    
                    let insertionIndexPaths = diff.insertions.map({ NSIndexPath(forItem: $0.idx, inSection: self.sectionIndex) })
                    let deletionIndexPaths = diff.deletions.map({ NSIndexPath(forItem: $0.idx, inSection: self.sectionIndex) })
                    
                    self.collectionView?.insertItemsAtIndexPaths(insertionIndexPaths)
                    self.collectionView?.deleteItemsAtIndexPaths(deletionIndexPaths)
                }, completion: nil)
            }
            
        }
    }
    
}

#endif
