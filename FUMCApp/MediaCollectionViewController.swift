//
//  MediaCollectionViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

let reuseIdentifier = "MediaCell"

class MediaCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet private var mediaLayout: CollectionViewLayout!
    private let numberOfCells = 3
    private var showingCells = 0
    private var timer: NSTimer?
    private var modalWebViewController = UIViewController()
    private var modalTableViewController = UITableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.08, target: self, selector: "addCell", userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mediaCellSelection") {
            var tableViewController = segue.destinationViewController as MediaTableViewController
            var indexPath = sender as NSIndexPath
            switch (indexPath.item) {
                case 0:
                    tableViewController.dataSource = BulletinsDataSource(delegate: tableViewController)
                    break
                case 1:
                    tableViewController.dataSource = WitnessesDataSource(delegate: tableViewController)
                    break
                case 2:
                    tableViewController.title = "Sermon Archive"
                    break
                default:
                    break
            }
        }
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showingCells
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CollectionViewCell
        
        switch (indexPath.item) {
            case 0:
                cell.imageView.image = UIImage(named: "bulletin")
                cell.label.text = "BULLETIN"
                break
            case 1:
                cell.label.text = "WITNESS"
                cell.imageView.image = UIImage(named: "witness")
                break
            case 2:
                cell.label.text = "SERMONS"
                cell.imageView.image = UIImage(named: "sermons")
                break
            default:
                break
        }
    
        return cell
    }
    
    func addCell() {
        if (self.showingCells == self.numberOfCells) {
            self.timer!.invalidate()
        } else {
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.showingCells++, inSection: 0)])
            }, completion: nil)
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(collectionView: UICollectionView!, shouldHighlightItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView!, shouldSelectItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView!, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView!, canPerformAction action: String!, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView!, performAction action: String!, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) {
    
    }
    */
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("mediaCellSelection", sender: indexPath)
    }

}
