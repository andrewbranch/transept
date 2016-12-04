//
//  DirectoryDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 5/26/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import RealmSwift

open class DirectoryDataSource: NSObject, UITableViewDataSource {
    
    private let realm = try! Realm()
    private var notificationToken: NotificationToken?
    private var data: Results<Member>!
    open var delegate: DirectoryDataSourceDelegate?
    open var title = "Directory"
    
    required public init(delegate: DirectoryDataSourceDelegate?) {
        super.init()
        self.delegate = delegate
        data = realm
            .objects(Member.self)
            .filter("isDeleted == false")
            .sorted(by: [
                SortDescriptor(property: "lastName"),
                SortDescriptor(property: "firstName")
            ])
        
        notificationToken = data.addNotificationBlock { [weak self] _ in
            self?.delegate?.dataSourceUpdatedMembers(dataSource: self!)
        }
    }
    
    open func refresh() {
        delegate?.dataSourceStartedLoading(dataSource: self)
        API.shared().getMembers() { [weak self] members in
            if (try? members.value()) == nil {
                // TODO clean up this error
                self?.delegate?.dataSource(self!, failedWith: API.Error.unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
            }
        }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directoryTableViewCell", for: indexPath)
        let member = data[indexPath.row]
        cell.textLabel!.text = "\(member.firstName!) \(member.lastName!)"
        return cell
    }
}
