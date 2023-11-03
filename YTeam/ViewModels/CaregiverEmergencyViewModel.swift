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
import FirebaseStorage

class CaregiverEmergencyViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate  {
    @Published var invites: [Invite] = []
    @Published var user: User?
    @Published var userData: UserData?
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

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
        PTT.shared.requestBeginTransmitting()
    }
    
    func stopRecording() {
        PTT.shared.stopTransmitting()
    }
    
    
    func fetchAllRecording(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        let voiceRef = storageRef.child("voice/test.aac")

        // Create local filesystem URL
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("CO-Voice : download.aac")

        // Download to the local filesystem
        let downloadTask = voiceRef.write(toFile: fileName) { url, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // Local file URL for "images/island.jpg" is returned
              self.recordingsList = []
              let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
              let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)

              print("downloaded: ", url)
              for i in directoryContents {
                  self.recordingsList.append(i)
              }
          }
        }
    }
    
    func startPlaying(url : URL) {
        print("playing: ", url)
      
        let playSession = AVAudioSession.sharedInstance()
            
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Playing failed in Device")
        }
            
        do {
            let data = try Data(contentsOf: url)
            audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: "aac")
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()

                
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
        print("delete: ", url)
        do {
            try FileManager.default.removeItem(at : url)
        } catch {
            print("Can't delete")
        }
            
        for i in 0..<recordingsList.count {
            
            if recordingsList[i] == url {
                recordingsList.remove(at : i)
                    
                break
            }
        }
    }
}
