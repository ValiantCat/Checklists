//
//  Checklist.swift
//  Checklists
//
//  Created by M.I. Hollemans on 18/09/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit

class Checklist: NSObject, NSCoding {
  var name = ""
  var items = [ChecklistItem]()
  var iconName: String

  convenience init(name: String) {
    self.init(name: name, iconName: "No Icon")
  }

  init(name: String, iconName: String) {
    self.name = name
    self.iconName = iconName
    super.init()
  }

  required init(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObjectForKey("Name") as! String
    items = aDecoder.decodeObjectForKey("Items")as!  [ChecklistItem]
    iconName = aDecoder.decodeObjectForKey("IconName")as! String
    super.init()
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "Name")
    aCoder.encodeObject(items, forKey: "Items")
    aCoder.encodeObject(iconName, forKey: "IconName")
  }

  func countUncheckedItems() -> Int {
    var count = 0
    for item in items {
      if !item.checked {
        count += 1
      }
    }
    return count
  }

  /*
  // The functional programming version of countUncheckedItems()
  func countUncheckedItems() -> Int {
    return reduce(items, 0) { cnt, item in cnt + (item.checked ? 0 : 1) }
  }
  */
}
