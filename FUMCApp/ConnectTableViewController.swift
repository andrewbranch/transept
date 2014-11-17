//
//  ConnectTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/15/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import AddressBookUI

class ConnectTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let podcastURL = NSURL(string: "itms-pcast://itunes.apple.com/us/podcast/first-umc-of-pensacola-fl/id313924198?mt=2&uo=4")
    private let font = UIFont(name: "BebasNeue Bold", size: 10)
    private let labels = [
        NSAttributedString(string: "Phone", attributes: [NSKernAttributeName: 4]),
        NSAttributedString(string: "Email", attributes: [NSKernAttributeName: 4]),
        NSAttributedString(string: "Website", attributes: [NSKernAttributeName: 4]),
        NSAttributedString(string: "Prayer Request", attributes: [NSKernAttributeName: 4])
    ]
    private let images = [UIImage(named: "phone"), UIImage(named: "email"), UIImage(named: "globe"), UIImage(named: "hands")]
    private var contact: ABRecordRef?
    private let contactViewController = ABUnknownPersonViewController()
    
    func createMultiStringRef(kPropertyType: Int) -> ABMutableMultiValueRef {
        let propertyType: NSNumber = kPropertyType
        return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.registerNib(UINib(nibName: "ConnectTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "connectTableCell")

        
        self.contact = ABPersonCreate().takeUnretainedValue()
        ABRecordSetValue(self.contact!, kABPersonOrganizationProperty, "First United Methodist Church" as CFStringRef, nil)
        
        let phoneNumber: ABMutableMultiValueRef = createMultiStringRef(kABMultiStringPropertyType)
        let url: ABMutableMultiValueRef = createMultiStringRef(kABMultiStringPropertyType)
        let email: ABMutableMultiValueRef = createMultiStringRef(kABMultiStringPropertyType)
        ABMultiValueAddValueAndLabel(phoneNumber, "8504321434" as CFStringRef, kABPersonPhoneMainLabel, nil)
        ABMultiValueAddValueAndLabel(url, "http://fumcpensacola.com" as CFStringRef, kABPersonHomePageLabel, nil)
        ABMultiValueAddValueAndLabel(email, "fumc@pensacolafirstchurch.com" as CFStringRef, kABWorkLabel, nil)
        ABRecordSetValue(self.contact!, kABPersonPhoneProperty, phoneNumber, nil)
        ABRecordSetValue(self.contact!, kABPersonURLProperty, url, nil)
        ABRecordSetValue(self.contact!, kABPersonEmailProperty, email, nil)
        ABPersonSetImageData(self.contact!, UIImageJPEGRepresentation(UIImage(named: "contact-image"), 0.7), nil)

        
        let address: ABMutableMultiValueRef = createMultiStringRef(kABMultiDictionaryPropertyType)
        let addressDictionary = NSDictionary(dictionary: [
            kABPersonAddressStreetKey: "6 East Wright Street",
            kABPersonAddressCityKey: "Pensacola",
            kABPersonAddressStateKey: "Florida",
            kABPersonAddressZIPKey: "32501",
            kABPersonAddressCountryKey: "United States"
        ])
        ABMultiValueAddValueAndLabel(address, addressDictionary as CFDictionaryRef, kABWorkLabel, nil)
        ABRecordSetValue(self.contact!, kABPersonAddressProperty, address, nil)
        
        self.contactViewController.displayedPerson = self.contact!
        self.contactViewController.allowsActions = true
        self.contactViewController.allowsAddingToAddressBook = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    @IBAction func displayContactCard() {
        self.navigationController!.pushViewController(self.contactViewController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.labels.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("connectTableCell", forIndexPath: indexPath) as ConnectTableViewCell
        
        cell.iconView!.image = self.images[indexPath.row]
        cell.label!.attributedText = self.labels[indexPath.row]
        if let font = self.font {
            cell.label!.font = font
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
            case 0:
                UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://18504321434")!)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                break
            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:fumc@pensacolafirstchurch.com")!)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                break
            case 2:
                UIApplication.sharedApplication().openURL(NSURL(string: "http://fumcpensacola.com")!)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                break
            default:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
