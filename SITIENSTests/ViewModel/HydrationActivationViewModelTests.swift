//
//  HydrationActivationViewModelTests.swift
//  SITIENSTests
//
//  Created by Modibo on 14/05/2025.
//
import Testing
import XCTest
@testable import SITIENS

struct HydrationActivationViewModelTests {

    @Test func formatTimerWhenAddNewElement() async throws {
        //Gieven
        let hydrationActivationViewModel = HydrationActivationViewModel()
        let secondes = 10
        //When
        let fomatTimer = hydrationActivationViewModel.formatTimer(secondes)
        
        //Then
        #expect(fomatTimer == "00:00:10")
    }
    
    @Test func formatTimerWhenAddNewHour() async throws {
        //Gieven
        let hydrationActivationViewModel = HydrationActivationViewModel()
        let hours = 7200
        //When
        let fomatTimer = hydrationActivationViewModel.formatHour(hours)
        
        //Then
        #expect(fomatTimer == "2 heures")
    }
    
    @Test func formatTimerWhenHourIfegaltoZero() async throws {
        //Gieven
        let hydrationActivationViewModel = HydrationActivationViewModel()
        let hours = 0
        let secondes = hours / 3600

        let minutes = (secondes % 3600) / 60
        //When
        let fomatTimer = hydrationActivationViewModel.formatHour(hours)
        
        //Then
        #expect(fomatTimer == "\(minutes) \(minutes > 1 ? "minutes" : "minute")")
        
    }
//    
//    @Test func formatTimerWhenMinutesIfEgaltoZero() async throws {
//        //Gieven
//        let hydrationActivationViewModel = HydrationActivationViewModel()
//        let hours = 7200
//        let minutes = (hours % 3600) / 60
//        //When
//        let fomatTimer = hydrationActivationViewModel.formatHour(minutes)
//        
//        //Then
//        #expect(fomatTimer == "\(hours) \(hours > 1 ? "heures" : "heure")")
//    }

    @Test func whenPlayingSound() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        let sound = "fake"
        //When
        hydrationActivationViewModel.playingSound(audioFile: sound)
        
        //Then
        #expect(mock.messageError.isEmpty == true)
        #expect(mock.isPlaying == true)
        #expect(mock.sound == sound)
    }
    
    @Test func whenPlayingSoundIsEmpty() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        let sound = ""
        //When
        hydrationActivationViewModel.playingSound(audioFile: sound)
        
        //Then
        #expect(mock.messageError.isEmpty == false)
        #expect(mock.messageError == "audioFile is empty")
        #expect(mock.isPlaying == false)
    }
    
    @Test func whenPlayingSoundThrowError() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        mock.throwError = true
        let sound = "fake"
        //When
        hydrationActivationViewModel.playingSound(audioFile: sound)
        
        //Then
        #expect(mock.isPlaying == false)
        #expect(mock.messageError == "There are some errors")

    }
    
    @Test func stopPlayingSound() async throws {
            //Gieven
            let mock = MocksHydradationActivation()
            let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
            //When
            hydrationActivationViewModel.stopPlaying()
            
            //Then
            #expect(mock.isPlaying == true)
    }
    
    @Test func sopPlaingSoundThrowError() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        mock.throwError = true
        //When
        hydrationActivationViewModel.stopPlaying()
        
        //Then
        #expect(mock.isPlaying == false)
        #expect(mock.messageError == "impossible to stop playing to song")
    }
    
    @Test func playSound() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        let sound = "fakeSound"
        //When
        hydrationActivationViewModel.playSound(sound: sound)
        
        //Then
        #expect(mock.sound == sound)
        #expect(mock.messageError == "")
        #expect(mock.isPlaying == true)
    }
    
    @Test func playSoundWithError() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        let sound = "fakeSound"
        mock.throwError = true
        //When
        hydrationActivationViewModel.playSound(sound: sound)
        
        //Then
        #expect(mock.messageError == "There are some errors")
        #expect(mock.isPlaying == false)
    }
    
    @Test func playSoundWhen_nameSoungIsNil() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        let sound = ""
        //When
        hydrationActivationViewModel.playSound(sound: sound)
        
        //Then
        #expect(mock.messageError == "audioFile is empty")
        #expect(mock.isPlaying == false)
    }
    
    @Test func WhenAuthorizationStatusIsNotDetermined() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        mock.throwError = true
        //When
        hydrationActivationViewModel.authorization()
        //Then
        #expect(mock.messageError == "Your don't have authorization")
        
    }

    
    @Test func WhenAuthorizationStatusIsValid() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        //When
        hydrationActivationViewModel.authorization()
        //Then
        #expect(mock.messageError.isEmpty == true)
        
    }
    
    @Test func WhenNotificationIsOn() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        //When
        hydrationActivationViewModel.scheduleNotification(in: 600)
        //Then
        #expect(mock.messageError.isEmpty == true)
        #expect(mock.scheduledSeconds == 600)
    }
    
    @Test func WhenNotificationIsCancelled() async throws {
        //Given
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        hydrationActivationViewModel.scheduleNotification(in: 600)
        //When
        hydrationActivationViewModel.cancelNotification()
        //Then
        #expect(mock.scheduledSeconds == nil)
    }
    
    @Test func WhenNotificationThrowError() async throws {
        //Gieven
        let mock = MocksHydradationActivation()
        let hydrationActivationViewModel = HydrationActivationViewModel(hydrationProtocol: mock)
        mock.throwError = true
        //When
        hydrationActivationViewModel.scheduleNotification(in: 600)
        //Then
        #expect(mock.messageError == "Impossible for send notification")
        #expect(mock.scheduledSeconds == nil)
    }
}
