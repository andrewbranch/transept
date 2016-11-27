//
//  ConnectTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/15/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import AddressBookUI
import Crashlytics

class ConnectTableViewController: UITableViewController {
    
    fileprivate var prayerRequestViewController: PrayerRequestViewController?
    fileprivate let podcastURL = URL(string: "itms-pcast://itunes.apple.com/us/podcast/first-umc-of-pensacola-fl/id313924198?mt=2&uo=4")
    fileprivate let labels = [
        NSAttributedString(string: "Phone", attributes: [NSKernAttributeName: 4]),
        NSAttributedString(string: "Email", attributes: [NSKernAttributeName: 4]),
        NSAttributedString(string: "Website", attributes: [NSKernAttributeName: 4]),
        NSAttributedString(string: "Prayer Request", attributes: [NSKernAttributeName: 4])
    ]
    fileprivate let images = [UIImage(named: "phone"), UIImage(named: "email"), UIImage(named: "globe"), UIImage(named: "hands")]
    fileprivate var contact: ABRecord?
    fileprivate let contactViewController = ABUnknownPersonViewController()
    
    func createMultiStringRef(_ kPropertyType: Int) -> ABMutableMultiValue {
        let propertyType: NSNumber = NSNumber(kPropertyType)
        return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.uint32Value).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prayerRequestViewController = self.storyboard!.instantiateViewController(withIdentifier: "prayerRequestViewController") as? PrayerRequestViewController
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(UINib(nibName: "ConnectTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "connectTableCell")
        self.tableView.register(UINib(nibName: "ConnectTableFooterView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "ConnectTableFooterViewIdentifier")

        
        self.contact = ABPersonCreate().takeUnretainedValue()
        ABRecordSetValue(self.contact!, kABPersonOrganizationProperty, "First United Methodist Church" as CFString, nil)
        
        let phoneNumber: ABMutableMultiValue = createMultiStringRef(kABMultiStringPropertyType)
        let url: ABMutableMultiValue = createMultiStringRef(kABMultiStringPropertyType)
        let email: ABMutableMultiValue = createMultiStringRef(kABMultiStringPropertyType)
        ABMultiValueAddValueAndLabel(phoneNumber, "8504321434" as CFString, kABPersonPhoneMainLabel, nil)
        ABMultiValueAddValueAndLabel(url, "http://fumcpensacola.com" as CFString, kABPersonHomePageLabel, nil)
        ABMultiValueAddValueAndLabel(email, "fumc@pensacolafirstchurch.com" as CFString, kABWorkLabel, nil)
        ABRecordSetValue(self.contact!, kABPersonPhoneProperty, phoneNumber, nil)
        ABRecordSetValue(self.contact!, kABPersonURLProperty, url, nil)
        ABRecordSetValue(self.contact!, kABPersonEmailProperty, email, nil)
        ABPersonSetImageData(self.contact!, UIImageJPEGRepresentation(UIImage(named: "contact-image")!, 0.7) as CFData!, nil)

        
        let address: ABMutableMultiValue = createMultiStringRef(kABMultiDictionaryPropertyType)
        let addressDictionary = NSDictionary(dictionary: [
            kABPersonAddressStreetKey: "6 East Wright Street",
            kABPersonAddressCityKey: "Pensacola",
            kABPersonAddressStateKey: "Florida",
            kABPersonAddressZIPKey: "32501",
            kABPersonAddressCountryKey: "United States"
        ])
        ABMultiValueAddValueAndLabel(address, addressDictionary as CFDictionary, kABWorkLabel, nil)
        ABRecordSetValue(self.contact!, kABPersonAddressProperty, address, nil)
        
        self.contactViewController.displayedPerson = self.contact!
        self.contactViewController.allowsActions = true
        self.contactViewController.allowsAddingToAddressBook = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed tab", customAttributes: ["Name": "Connect"])
        #endif
    }
    
    @IBAction func displayContactCard() {
        self.navigationController!.pushViewController(self.contactViewController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.labels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "connectTableCell", for: indexPath) as! ConnectTableViewCell
        
        cell.iconView!.image = self.images[indexPath.row]
        cell.label!.attributedText = self.labels[indexPath.row]
        cell.label!.font = UIFont.fumcAltFontBold22
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ConnectTableFooterViewIdentifier") as! ConnectTableFooterView
        return footer
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
            case 0:
                UIApplication.shared.openURL(URL(string: "telprompt://18504321434")!)
                tableView.deselectRow(at: indexPath, animated: true)
                break
            case 1:
                UIApplication.shared.openURL(URL(string: "mailto:fumc@pensacolafirstchurch.com")!)
                tableView.deselectRow(at: indexPath, animated: true)
                break
            case 2:
                UIApplication.shared.openURL(URL(string: "http://fumcpensacola.com")!)
                tableView.deselectRow(at: indexPath, animated: true)
                break
            case 3:
                // For some reason, using the segue here results in the prayerRequestViewController.navigationController
                // being nil the second time you navigate to it
                self.navigationController!.pushViewController(self.prayerRequestViewController!, animated: true)
            default:
                tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    


    // MARK: - Navigation

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//    }

}
