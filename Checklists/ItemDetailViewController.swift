//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by M.I. Hollemans on 16/09/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit

protocol ItemDetailViewControllerDelegate: class {
  func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
  func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem)
  func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  @IBOutlet weak var shouldRemindSwitch: UISwitch!
  @IBOutlet weak var dueDateLabel: UILabel!

  weak var delegate: ItemDetailViewControllerDelegate?

  var itemToEdit: ChecklistItem?

  var dueDate = NSDate()
  var datePickerVisible = false

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 44
   
    if let item = itemToEdit {
      title = "Edit Item"
      textField.text = item.text
      doneBarButton.enabled = true
      shouldRemindSwitch.on = item.shouldRemind
      dueDate = item.dueDate
    }
    
    updateDueDateLabel()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }

  @IBAction func cancel() {
    delegate?.itemDetailViewControllerDidCancel(self)
  }

  @IBAction func done() {
    if let item = itemToEdit {
      item.text = textField.text
      item.shouldRemind = shouldRemindSwitch.on
      item.dueDate = dueDate
      item.scheduleNotification()
      delegate?.itemDetailViewController(self, didFinishEditingItem: item)
      
    } else {
      let item = ChecklistItem()
      item.text = textField.text
      item.checked = false
      item.shouldRemind = shouldRemindSwitch.on
      item.dueDate = dueDate
      item.scheduleNotification()
      delegate?.itemDetailViewController(self, didFinishAddingItem: item)
    }
  }

  @IBAction func shouldRemindToggled(switchControl: UISwitch) {
    textField.resignFirstResponder()

    if switchControl.on {
      let notificationSettings = UIUserNotificationSettings(forTypes: .Alert | .Sound, categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 1 && indexPath.row == 2 {

      var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("DatePickerCell") as? UITableViewCell
      if cell == nil {
        cell = UITableViewCell(style: .Default, reuseIdentifier: "DatePickerCell")
        cell.selectionStyle = .None
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320, height: 216))
        datePicker.tag = 100
        cell.contentView.addSubview(datePicker)
        
        datePicker.addTarget(self, action: Selector("dateChanged:"), forControlEvents: .ValueChanged)
      }
      return cell
      
    } else {
      return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 && datePickerVisible {
      return 3
    } else {
      return super.tableView(tableView, numberOfRowsInSection: section)
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 1 && indexPath.row == 2 {
      return 217
    } else {
      return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    textField.resignFirstResponder()
    
    if indexPath.section == 1 && indexPath.row == 1 {
      if !datePickerVisible {
        showDatePicker()
      } else {
        hideDatePicker()
      }
    }
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if indexPath.section == 1 && indexPath.row == 1 {
      return indexPath
    } else {
      return nil
    }
  }

  override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
    if indexPath.section == 1 && indexPath.row == 2 {
      indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
    }
    return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
  }

  func textField(textField: UITextField,shouldChangeCharactersInRange range: NSRange,replacementString string: String) -> Bool {
      
    let oldText: NSString = textField.text
    let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)

    doneBarButton.enabled = (newText.length > 0)
    return true
  }

  func textFieldDidBeginEditing(textField: UITextField!) {
    hideDatePicker()
  }

  func updateDueDateLabel() {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    dueDateLabel.text = formatter.stringFromDate(dueDate)
  }

  func showDatePicker() {
    datePickerVisible = true
    
    let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
    let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)

    if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
      dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
    }
    
    tableView.beginUpdates()
    tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
    tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
    tableView.endUpdates()

    if let pickerCell = tableView.cellForRowAtIndexPath(indexPathDatePicker) {
      let datePicker = pickerCell.viewWithTag(100) as! UIDatePicker
      datePicker.setDate(dueDate, animated: false)
    }
  }

  func hideDatePicker() {
    if datePickerVisible {
      datePickerVisible = false
      
      let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
      let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
      
      if let cell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
        cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
      }
      
      tableView.beginUpdates()
      tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
      tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
      tableView.endUpdates()
    }
  }

  func dateChanged(datePicker: UIDatePicker) {
    dueDate = datePicker.date
    updateDueDateLabel()
  }
}
