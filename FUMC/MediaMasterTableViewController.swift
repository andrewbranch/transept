//
//  MediaMasterTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/14/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import Crashlytics

class MediaMasterTableViewController: UITableViewController {
    
    fileprivate let labels = [NSAttributedString(string: "Bulletins", attributes: [NSKernAttributeName: 5]), NSAttributedString(string: "Witnesses", attributes: [NSKernAttributeName: 5]), NSAttributedString(string: "Videos", attributes: [NSKernAttributeName: 5])]
    fileprivate let images = [UIImage(named: "bulletins-dark"), UIImage(named: "witnesses-dark"), UIImage(named: "sermons-dark")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(UINib(nibName: "MediaMasterTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "mediaMasterTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed tab", customAttributes: ["Name": "Media"])
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.labels.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaMasterTableViewCell", for: indexPath) as! MediaMasterTableViewCell

        cell.iconView!.image = self.images[indexPath.row]
        cell.label!.attributedText = self.labels[indexPath.row]
        cell.label!.font = UIFont.fumcAltFontBold30
        
        return cell
    }

    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            self.performSegue(withIdentifier: "videosSegueIdentifier", sender: nil)
        } else {
            self.performSegue(withIdentifier: "mediaMasterCellSelection", sender: indexPath)
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "mediaMasterCellSelection") {
            let tableViewController = segue.destination as! MediaTableViewController
            let indexPath = sender as! IndexPath
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
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
