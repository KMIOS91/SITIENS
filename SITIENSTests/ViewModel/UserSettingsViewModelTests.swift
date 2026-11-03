//
//  UserSettingsViewModelTests.swift
//  SITIENSTests
//
//  Created by Modibo on 14/05/2025.
//

import Testing
import XCTest
@testable import SITIENS

struct UserSettingsViewModelTests {

    @Test func updateTypeWithNewNameIsEgaltoNourrissons() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Nourrissons"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 2.3332/1000)
       
    }
    
    @Test func updateTypeWithNewNameIsEgaltoWomen() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Femmes enceintes"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 8.36/1000)
    }
    
    @Test func updateTypeWithNewNameIsEgaltoGrandFatherOrMother() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes âgées"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 6.66/1000)
    }
    
    @Test func updateTypeWithNewNameIsEgaltosportifs() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Sportifs"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.01)
    }

    @Test func updateTypeWithChildsAndTeenagers() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Enfants et adolescents"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.00836)
    }
    
    @Test func updateTypeWithHotEnvironment() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Travailleurs en environnement chaud"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.01)
    }
    
    @Test func updateTypeWitPeopleWithChronicIllnesses() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes souffrant de maladies chroniques"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.00666)
    }

    @Test func updateTypeWitPeopleWithOverweightOrObesePeople() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes en surpoids ou obèses"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.01)
    }
    
    @Test func updateTypeWitPeopleInHighAltitude() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Voyageurs ou personnes en altitude"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.01)
    }

    @Test func updateTypeWitPeopleOnMedication() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes sous traitement médicamenteux"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.00666)
    }

    @Test func updateTypeWithNewName() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "FakeName"
        //When
        let user = userSettingsViewModel.updateType(name: name)
        //Then
        #expect(user == 0.0)
    }
 
    @Test func updateWaterWhenResultIsEgalToNourrissons() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Nourrissons"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 0.7)
    }
    
    @Test func updateWaterWhenResultIsEgalToWomen() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Femmes enceintes"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 2.5)
    }
    
    @Test func updateWaterWhenResultIsEgalToGrandFatherOrMother() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes âgées"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 2)
    }
    
    @Test func updateWaterWhenResultIsEgalToSportifs() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Sportifs"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 3)
    }
    
    @Test func updateWaterWhenResultIsEgalToChildsAndTeenagers() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Enfants et adolescents"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 2.5)
    }
    
    @Test func updateWaterWhenResultIsEgalToHotEnvironment() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Travailleurs en environnement chaud"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 3)
    }
    
    @Test func updateWaterWhenResultIsEgalToPeopleWithChronicIllnesses() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes souffrant de maladies chroniques"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 2)
    }
    
    @Test func updateWaterWhenResultIsEgalToPeopleWithOverweightOrObesePeople() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes en surpoids ou obèses"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 3)
    }
    
    @Test func updateWaterWhenResultIsEgalToPeopleInHighAltitude() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Voyageurs ou personnes en altitude"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 3)
    }
    
    @Test func updateWaterWhenResultIsEgalToPeopleOnMedication() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "Personnes sous traitement médicamenteux"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 2)
    }
    
    @Test func updateWater() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        let name = "FakeName"
        //When
        let user = userSettingsViewModel.updateWater(type: name)
        //Then
        #expect(user == 0)
    }
    
    @Test func UpdateQuantityOfWater() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        
        //When
        let user = userSettingsViewModel.uptateQuanittyOfWater(
            quantityWater: "Nourrissons",
            chooseBottle: "Petit – 200 ml"
        )
      
        //Then
        #expect(user == 3.5)
    }

    @Test func uantityWaterNumberIsMiddleBottle() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        //When
        let user = userSettingsViewModel.quantityWaterNumber(chooseBottle: "Moyen – 300 ml")
        
        //Then
        #expect(user == 300)
    }
    
    @Test func uantityWaterNumberIsLargeBottle() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        //When
        let user = userSettingsViewModel.quantityWaterNumber(chooseBottle: "Grand – 500 ml")
        
        //Then
        #expect(user == 500)
    }
    
    @Test func uantityWaterNumberIsEmpty() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        //When
        let user = userSettingsViewModel.quantityWaterNumber(chooseBottle: "")
        
        //Then
        #expect(user == 0)
    }
    
    @Test func showNumberOfGlassForDrink() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        
        //When
        let user = userSettingsViewModel.showNumberOfGlass(chooseBottle: "Grand – 500 ml", name: "Nourrissons")
        //Then
        #expect(user == 0.7142857142857143)
    }
    
    @Test func uptateQuanittyOfWaterAndWhenQuantityWaterIsEgalToZero() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        
        //When
        let user = userSettingsViewModel.uptateQuanittyOfWater2(
            quantityWater:"Nil",
            chooseBottle: "Grand – 500 ml"
        )
        
        //Then
        #expect(user == 0 )
        
    }
    
    @Test func uptateQuanittyOfWaterAndWhenBottleIsEmpty() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        
        //When
        let user = userSettingsViewModel.uptateQuanittyOfWater2(
            quantityWater:"Nourrissons",
            chooseBottle: "Nil"
        )
        
        //Then
        #expect(user == 0 )
        
    }
    
    @Test func uptateQuanittyOfWaterWhenNoThrowsErrors() async throws {
        //Given
        let userSettingsViewModel = UserSettingsViewModel()
        
        //When
        let user = Int(userSettingsViewModel.uptateQuanittyOfWater2(
            quantityWater:"Nourrissons",
            chooseBottle: "Grand – 500 ml"
        )) 
        
        //Then
        #expect(user ==  214)
        
    }
    
    @Test func chooseBottleOfWaterWhenYouWantToDrinkWithLargeBottle() async throws {
    //Given
        let userSettingsViewModel = UserSettingsViewModel()
    
    //When
        let user = userSettingsViewModel.chooseBottleOfWater(
            name: "Grand – 500 ml"
        )
    
    //Then
    #expect(user == "LargeGlace")
        
    }
    
    @Test func chooseBottleOfWaterWhenYouWantToDrinkWithMiddleBottle() async throws {
        //Given
            let userSettingsViewModel = UserSettingsViewModel()
        
        //When
            let user = userSettingsViewModel.chooseBottleOfWater(
                name: "Moyen – 300 ml"
            )
        
        //Then
        #expect(user == "MediumGlace")
            
        }
    
    @Test func chooseBottleOfWaterWhenYouWantToDrinkWithSmallBottle() async throws {
        //Given
            let userSettingsViewModel = UserSettingsViewModel()
        
        //When
            let user = userSettingsViewModel.chooseBottleOfWater(
                name: "Petit – 200 ml"
            )
        
        //Then
        #expect(user == "SmallGlace")
            
        }
    
    @Test func chooseBottleOfWaterWhenIsEmpty() async throws {
        //Given
            let userSettingsViewModel = UserSettingsViewModel()
        
        //When
            let user = userSettingsViewModel.chooseBottleOfWater(
                name: "Nil"
            )
        
        //Then
        #expect(user == "")
            
        }

    // MARK: - Remise à zéro quotidienne

    private var parisCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        parisCalendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    @Test func isNewDayWhenNothingTrackedYet() {
        let viewModel = UserSettingsViewModel()
        #expect(viewModel.isNewDay(lastTracking: 0, now: date(3, 12), calendar: parisCalendar) == false)
    }

    @Test func isNewDayWhenSameDay() {
        let viewModel = UserSettingsViewModel()
        let last = date(3, 0, 5).timeIntervalSince1970
        #expect(viewModel.isNewDay(lastTracking: last, now: date(3, 23, 59), calendar: parisCalendar) == false)
    }

    @Test func isNewDayAfterMidnight() {
        let viewModel = UserSettingsViewModel()
        let last = date(3, 23, 50).timeIntervalSince1970
        #expect(viewModel.isNewDay(lastTracking: last, now: date(4, 0, 10), calendar: parisCalendar) == true)
    }
}
