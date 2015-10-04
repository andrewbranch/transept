//
//  MediaMasterTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/14/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class MediaMasterTableViewController: UITableViewController {
    
    private let labels = [NSAttributedString(string: "Bulletins", attributes: [NSKernAttributeName: 5]), NSAttributedString(string: "Witnesses", attributes: [NSKernAttributeName: 5]), NSAttributedString(string: "Videos", attributes: [NSKernAttributeName: 5])]
    private let images = [UIImage(named: "bulletins-dark"), UIImage(named: "witnesses-dark"), UIImage(named: "sermons-dark")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.registerNib(UINib(nibName: "MediaMasterTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "mediaMasterTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.labels.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaMasterTableViewCell", forIndexPath: indexPath) as! MediaMasterTableViewCell

        cell.iconView!.image = self.images[indexPath.row]
        cell.label!.attributedText = self.labels[indexPath.row]
        cell.label!.font = UIFont.fumcAltFontBold30
        
        return cell
    }

    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 2) {
            self.performSegueWithIdentifier("videosSegueIdentifier", sender: nil)
        } else {
            self.performSegueWithIdentifier("mediaMasterCellSelection", sender: indexPath)
        }
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mediaMasterCellSelection") {
            let tableViewController = segue.destinationViewController as! MediaTableViewController
            let indexPath = sender as! NSIndexPath
            let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
            switch (indexPath.item) {
                
                case 0:
                    tableViewController.dataSource = appDelegate.bulletinsDataSource
                    appDelegate.bulletinsDataSource.delegate = tableViewController
                    break
                    
                case 1:
                    tableViewController.dataSource = appDelegate.witnessesDataSource
                    appDelegate.witnessesDataSource.delegate = tableViewController
                    break
                    
                default:
                    break
            }
        }
    }


}
