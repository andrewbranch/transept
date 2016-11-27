//
//  CalendarSettingsViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 12/4/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

@objc protocol CalendarsDataSourceDelegate {
    var tableView: UITableView? { get set }
    @objc optional func dataSourceDidStartLoadingAPI(_ dataSource: CalendarsDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(_ dataSource: CalendarsDataSource) -> Void
    func dataSource(_ dataSource: CalendarsDataSource, failedToLoadWithError error: NSError?) -> Void
}

class CalendarSettingsViewController: UIViewController, UITableViewDelegate, CalendarsDataSourceDelegate, ErrorAlertable {
    
    @IBOutlet var tableView: UITableView?
    var dataSource: CalendarsDataSource?
    var delegate: CalendarSettingsDelegate?
    var selectButton: UIButton?
    
    lazy var tableViewController: UITableViewController = {
        return UITableViewController(style: self.tableView!.style)
    }()
    
    var errorAlertToBeShown: UIAlertView?
    var lastCalendarIds = UserDefaults.standard.object(forKey: "selectedCalendarIds") as! [String]?
    var currentCalendarIds: [String]? = UserDefaults.standard.object(forKey: "selectedCalendarIds") as! [String]? {
        didSet (oldValue) {
            UserDefaults.standard.set(self.currentCalendarIds!, forKey: "selectedCalendarIds")
            setButtonText()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewController.tableView = self.tableView!
        self.tableViewController.tableView.delegate = self
        self.tableView!.register(UINib(nibName: "CalendarSettingsSelectTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "selectCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.currentCalendarIds == nil) {
            self.currentCalendarIds = self.dataSource!.calendars.map { $0.id }
        }
        self.tableView!.dataSource = self.dataSource!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let alert = self.errorAlertToBeShown {
            alert.show()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss() {
        self.delegate!.calendarSettingsController(self, didUpdateSelectionFrom: self.dataSource!.calendars.filter {
            self.lastCalendarIds!.index(of: $0.id) != nil
        }, to: self.dataSource!.calendars.filter {
            self.currentCalendarIds!.index(of: $0.id) != nil
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) { return }
        let calendar = self.dataSource!.calendarForIndexPath(indexPath)!
        if let cell = tableView.cellForRow(at: indexPath) as? CalendarSettingsTableViewCell {
            cell.setSelected(true, animated: false)
            cell.checkView!.color = calendar.color
        }
        self.currentCalendarIds!.append(calendar.id)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) { return }
        if let cell = tableView.cellForRow(at: indexPath) as? CalendarSettingsTableViewCell {
            cell.setSelected(false, animated: false)
            cell.checkView!.color = UIColor.lightGray
        }
        let index = self.currentCalendarIds!.index(of: self.dataSource!.calendarForIndexPath(indexPath)!.id)!
        self.currentCalendarIds!.remove(at: index)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let calendar = self.dataSource!.calendarForIndexPath(indexPath) {
            if (self.currentCalendarIds!.contains(calendar.id)) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            } else {
                (cell as! CalendarSettingsTableViewCell).checkView!.color = UIColor.lightGray
            }
        } else if (indexPath.row == 0) {
            if (self.selectButton == nil) {
                self.selectButton = (cell as! CalendarSettingsSelectTableViewCell).selectButton
                self.selectButton!.addTarget(self, action: #selector(CalendarSettingsViewController.toggleSelection(_:)), for: UIControlEvents.touchUpInside)
                setButtonText()
            }
        }
    }
    
    func toggleSelection(_ sender: UIButton!) {
        // Select all
        if (self.currentCalendarIds!.count < self.dataSource!.calendars.count) {
            for id in self.dataSource!.calendars.map({ $0.id }) - self.currentCalendarIds! {
                if let indexPath = self.dataSource!.indexPathForCalendarId(id) {
                    self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                    self.tableView(self.tableView!, didSelectRowAt: indexPath)
                }
            }
        // Select none
        } else {
            for id in self.currentCalendarIds! {
                if let indexPath = self.dataSource!.indexPathForCalendarId(id) {
                    self.tableView!.deselectRow(at: indexPath, animated: false)
                    self.tableView(self.tableView!, didDeselectRowAt: indexPath)
                }
            }
        }
    }
    
    func dataSourceDidFinishLoadingAPI(_ dataSource: CalendarsDataSource) {
        self.tableView?.reloadData()
    }
    
    func dataSource(_ dataSource: CalendarsDataSource, failedToLoadWithError error: NSError?) {
        ErrorAlerter.showLoadingAlertInViewController(self)
    }
    
    func setButtonText() {
        if let button = self.selectButton {
            UIView.setAnimationsEnabled(false)
            if (self.currentCalendarIds!.count == self.dataSource!.calendars.count) {
                button.setTitle("Select none", for: UIControlState())
            } else {
                button.setTitle("Select all", for: UIControlState())
            }
            UIView.setAnimationsEnabled(true)
        }
    }

}
