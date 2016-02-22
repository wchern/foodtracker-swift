//
//  DataController.swift
//  FoodTracker
//
//  Created by William Chern on 7/30/2015.
//  Copyright (c) 2015 William Chern. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let kUSDAItemCompleted = "USDAItemInstanceComplete"

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults (json: NSDictionary) -> [(name: String, idValue: String)] {
        var usdaItemsSearchResults: [(name: String, idValue: String)] = []
        var searchResult: (name: String, idValue: String)
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            
            for itemDictionary in results {
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"] as! NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as! String
                            let name:String = fieldsDictionary["item_name"]! as! String
                            searchResult = (name: name, idValue: idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
            
        }
        return usdaItemsSearchResults
    }
    
    func saveUSDAItemForId(idValue: String, json: NSDictionary) {
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"] as! [AnyObject]
            
            for itemDictionary in results {
                if itemDictionary["_id"] != nil && itemDictionary["_id"] as! String == idValue {
                    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                    
                    var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                    
                    let itemDictionaryId = itemDictionary["_id"] as! String
                    let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                    requestForUSDAItem.predicate = predicate
                    
                    var error:NSError?
                    
                    var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                    
                    if items?.count != 0 {
                        // The item is already saved
                        println("The item was already saved.")
                        return
                    }
                    else {
                        println("Now saved to CoreData.")
                        
                        let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                        
                        let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                        usdaItem.idValue = itemDictionary["_id"] as! String
                        usdaItem.dateAdded = NSDate()
                        
                        if itemDictionary["fields"] != nil {
                            let fieldsDictionary = itemDictionary["fields"]! as! NSDictionary
                            
                            if fieldsDictionary["item_name"] != nil {
                                usdaItem.name = fieldsDictionary["item_name"]! as! String
                            }
                            
                            if fieldsDictionary["usda_fields"] != nil {
                                let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as! NSDictionary
                                
                                // Calcium
                                //                                if usdaFieldsDictionary["CA"] != nil {
                                //                                    let calciumDictionary = usdaFieldsDictionary["CA"]! as! NSDictionary
                                //                                    let calciumValue:AnyObject = calciumDictionary["value"]!
                                //                                    usdaItem.calcium = "\(calciumValue)"
                                //                                }
                                //                                else {
                                //                                    usdaItem.calcium = "0"
                                //                                }
                                usdaItem.calcium = getUSDAFieldValues(usdaFieldsDictionary, field: "CA")
                                
                                // Carbohydrates
                                //                                if usdaFieldsDictionary["CHOCDF"] != nil {
                                //                                    let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as! NSDictionary
                                //                                    if carbohydrateDictionary["value"] != nil {
                                //                                        let carbohydrateValue:AnyObject = carbohydrateDictionary["value"]!
                                //                                        usdaItem.carbohydrate = "\(carbohydrateValue)"
                                //                                    }
                                //                                }
                                //                                else {
                                //                                    usdaItem.carbohydrate = "0"
                                //                                }
                                usdaItem.carbohydrate = getUSDAFieldValues(usdaFieldsDictionary, field: "CHOCDF")
                                
                                // Fat Total
                                usdaItem.fatTotal = getUSDAFieldValues(usdaFieldsDictionary, field: "FAT")
                                
                                // Cholesterol
                                usdaItem.cholesterol = getUSDAFieldValues(usdaFieldsDictionary, field: "CHOLE")
                                
                                // Protein
                                usdaItem.protein = getUSDAFieldValues(usdaFieldsDictionary, field: "PROCNT")
                                
                                // Sugar
                                usdaItem.sugar = getUSDAFieldValues(usdaFieldsDictionary, field: "SUGAR")
                                
                                // Vitamin C
                                usdaItem.vitaminC = getUSDAFieldValues(usdaFieldsDictionary, field: "VITC")
                                
                                // Energy
                                usdaItem.energy = getUSDAFieldValues(usdaFieldsDictionary, field: "ENERC_KCAL")
                                
                                (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
                                
                                NSNotificationCenter.defaultCenter().postNotificationName(kUSDAItemCompleted, object: usdaItem)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUSDAFieldValues (usdaFieldsDictionary: NSDictionary, field: String) -> String {
        if usdaFieldsDictionary[field] != nil {
            let fieldDictionary = usdaFieldsDictionary[field]! as! NSDictionary
            
            if fieldDictionary["value"] != nil {
                let fieldValue:AnyObject = fieldDictionary["value"]!
                return "\(fieldValue)"
            }
            else {
                return "0"
            }
        }
        else {
            return "0"
        }
    }
    
    
}