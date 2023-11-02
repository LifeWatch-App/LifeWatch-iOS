//
//  CaregiverEmergencyViewModel.swift
//  YTeam
//
//  Created by Yap Justin on 18/10/23.
//

import Foundation
import Combine
import FirebaseAuth
import AVFoundation

class CaregiverEmergencyViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate  {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    var recorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    @Published var recordingsList = [URL]()

    override init() {
        super.init()
        setupSubscribers()
        fetchAllRecording()
    }

    private func setupSubscribers() {
        service.$user
            .combineLatest(service.$userData, service.$invites)
            .sink { [weak self] user, userData, invites in
                self?.user = user
                self?.userData = userData
                self?.invites = invites
            }
            .store(in: &cancellables)
    }
    
    func sendRequestToSenior(email: String) {
        AuthService.shared.sendRequestToSenior(email: email)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
    
    func startRecording(){
            
            let recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Can not setup the Recording")
            }
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("CO-Voice : test.caf")
            
            
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            
            do {
                recorder = try AVAudioRecorder(url: fileName, settings: settings)
                recorder.prepareToRecord()
                recorder.record()
                
            } catch {
                print("Failed to Setup the Recording")
            }
        }
    
    func stopRecording() {
        recorder.stop()
    }
    
    func fetchAllRecording(){
            
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)

        for i in directoryContents {
            recordingsList.append(i)
        }
            
    }
    
    func startPlaying(url : URL) {
      
        let playSession = AVAudioSession.sharedInstance()
            
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
            
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
                
            for i in 0..<recordingsList.count{
                if recordingsList[i] == url{
                    /*ecordingsList[i].isPlaying = true*/
                }
            }
                
        } catch {
            print("Playing Failed")
            print(error)
        }
                
    }

    func stopPlaying(url : URL){
      
        audioPlayer.stop()
      
        for i in 0..<recordingsList.count {
            if recordingsList[i] == url {
//                recordingsList[i].isPlaying = false
            }
        }
      
    }
    
    func deleteRecording(url : URL){
        
        do {
            try FileManager.default.removeItem(at : url)
        } catch {
            print("Can't delete")
        }
            
        for i in 0..<recordingsList.count {
            
            if recordingsList[i] == url {
                stopPlaying(url: recordingsList[i])
                
                recordingsList.remove(at : i)
                    
                break
            }
        }
    }
}
