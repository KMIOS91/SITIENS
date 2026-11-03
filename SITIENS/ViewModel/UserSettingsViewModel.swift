//
//  UserSettingsViewModel.swift
//  SITIENS
//
//  Created by Modibo on 18/04/2025.
//

import Foundation

@Observable
class UserSettingsViewModel{
    
    func updateWater(type name:String) -> CGFloat{
        switch name  {
        case "Nourrissons":
            return 0.7
        case "Femmes enceintes":
            return 2.5
        case "Personnes âgées":
            return 2
        case "Sportifs":
            return 3
        case "Enfants et adolescents":
            return 2.5
        case "Travailleurs en environnement chaud":
            return 3
        case "Personnes souffrant de maladies chroniques":
            return 2
        case "Personnes en surpoids ou obèses":
            return 3
        case "Voyageurs ou personnes en altitude":
            return 3
        case "Personnes sous traitement médicamenteux":
            return 2
        default:
            return 0
        }
    }
    
    func updateType(name type: String) -> Double{
        switch type  {
        case "Nourrissons":
            return 2.3332/1000
        case "Femmes enceintes":
            return 8.36/1000
        case "Personnes âgées":
            return 6.66/1000
        case "Sportifs":
            return 1/100
        case "Enfants et adolescents":
            return 8.36/1000
        case "Travailleurs en environnement chaud":
            return 1/100
        case "Personnes souffrant de maladies chroniques":
            return 6.66/1000
        case "Personnes en surpoids ou obèses":
            return 1/100
        case "Voyageurs ou personnes en altitude":
            return 1/100
        case "Personnes sous traitement médicamenteux":
            return 6.66/1000
        default:
            return 0.0
        }
        
    }
    
    func uptateQuanittyOfWater(quantityWater  : String,chooseBottle:String) -> Double {
        let waterQuantity = quantityWaterNumber(chooseBottle:chooseBottle)
        let updatedProfile = updateWater(type :quantityWater)
        let totalMl = updatedProfile * 1000
        let result =  totalMl / CGFloat(waterQuantity)
        
        return result
    }
    
    func quantityWaterNumber(chooseBottle:String) -> Int {
        
        switch chooseBottle {
        case "Petit – 200 ml" :
            return  200
        case "Moyen – 300 ml" :
            return 300
        case "Grand – 500 ml" :
            return 500
        default :
            return  0
        }
    }
    
    func showNumberOfGlass(chooseBottle:String, name:String) -> Double {
        let waterQuantity = quantityWaterNumber(chooseBottle:chooseBottle)
        let updatedProfile = updateWater(type :name)
        let totalMl = updatedProfile * 1000
        let result = CGFloat(waterQuantity) / totalMl
        
        return  result
    }
    
    func uptateQuanittyOfWater2(quantityWater : String,chooseBottle:String) -> Double {
        let quantity = updateWater(type: quantityWater)//2_000
        
      
        let update = CGFloat(quantity) * 1000
        let limit : CGFloat = 300
                
        let bottle = CGFloat(quantityWaterNumber(chooseBottle: chooseBottle))// 200
      
        
        let waterUnits = update / bottle // 10
        
        
        guard quantity > 0  else{
            print("Error: Bottle size can't be zero")
            return 0
        }
    
        guard bottle > 0 else{
            print("Error: Bottle size can't be zero")
            return 0
        }
        
        let result = (limit / waterUnits) // 30
        
        
        print("update: \(update), bottle: \(bottle), waterUnits: \(waterUnits), result: \(result * 2)")

        return Double(result)
    }
    
    /// Indique si le suivi doit repartir à zéro : vrai quand le dernier ajout d'eau date d'un autre jour.
    /// `lastTracking` vaut 0 quand aucun verre n'a encore été ajouté.
    func isNewDay(lastTracking: TimeInterval, now: Date = .now, calendar: Calendar = .current) -> Bool {
        guard lastTracking > 0 else { return false }
        let lastDate = Date(timeIntervalSince1970: lastTracking)
        return !calendar.isDate(lastDate, inSameDayAs: now)
    }

    func chooseBottleOfWater(name type: String) -> String {
        switch type {
        case "Petit – 200 ml" :
            return "SmallGlace"
        case "Moyen – 300 ml" :
            return "MediumGlace"
        case "Grand – 500 ml" :
            return "LargeGlace"
        default :
            return ""
        }
    }
}
