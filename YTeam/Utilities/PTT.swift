//
//  PTT.swift
//  YTeam
//
//  Created by Yap Justin on 30/10/23.
//

import Foundation
import PushToTalk
import AVFAudio
import UIKit
import FirebaseStorage

class PTT: NSObject, PTChannelManagerDelegate, PTChannelRestorationDelegate, AVAudioPlayerDelegate {
    static let shared = PTT()
    var channelManager: PTChannelManager? = nil
    var channelUUID = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")
    var channelDescriptor = PTChannelDescriptor(name: "Care Team", image: UIImage())
    var recorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var isTransmiting = false
    @Published var isPlaying = false
    @Published var isJoined = false
    @Published var speakerName = ""
    @Published var speakerUID = ""
    var speaker = PTParticipant(name: "-", image: UIImage())
    @Published var status = "Hold to Talk"
    
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        return channelDescriptor
    }
    
    func channelManager(_ channelManager: PTChannelManager, didJoinChannel channelUUID: UUID, reason: PTChannelJoinReason) {
        let pttToken = UserDefaults.standard.value(forKey: "pttToken")
        if (pttToken != nil) {
            if (pttToken as! String != AuthService.shared.userData?.pttToken ?? "") {
                AuthService.shared.updatePTTToken(pttToken: pttToken! as! String)
            }
        }
        
        DispatchQueue.main.async{
            self.isJoined = true
        }
    }
    
    func channelManager(_ channelManager: PTChannelManager, didLeaveChannel channelUUID: UUID, reason: PTChannelLeaveReason) {
        DispatchQueue.main.async{
            self.isJoined = false
            self.isTransmiting = false
            self.isPlaying = false
            self.isJoined = false
            self.speakerName = ""
            self.speaker = PTParticipant(name: "-", image: UIImage())
            self.status = "Hold to Talk"
        }
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
        print("didBeginTransmittingFrom")
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
        isTransmiting = true
        DispatchQueue.main.async{
            self.status = "Connecting...\nPlease Keep Holding The Button"
          }
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didEndTransmittingFrom source: PTChannelTransmitRequestSource) {
    }
    
    func channelManager(_ channelManager: PTChannelManager, receivedEphemeralPushToken pushToken: Data) {
        let pttToken = pushToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("PTT TOKEN:", pttToken)
        
        UserDefaults.standard.set(pttToken, forKey: "pttToken")
        
        if AuthService.shared.userData?.pttToken != nil {
            if ((AuthService.shared.userData?.pttToken!) != pttToken) {
                AuthService.shared.updatePTTToken(pttToken: pttToken)
            }
        }
    }
    
    func incomingPushResult(channelManager: PTChannelManager, channelUUID: UUID, pushPayload: [String : Any]) -> PTPushResult {
        print("payload received")
        guard let activeSpeaker = pushPayload["activeSpeaker"] as? String else {
            return .leaveChannel
        }
        guard let activeSpeakerUID = pushPayload["uid"] as? String else {
            return .leaveChannel
        }
        print("payload received from: \(activeSpeaker)")
        DispatchQueue.main.async{
            self.isPlaying = true
            self.speakerName = activeSpeaker
            self.speakerUID = activeSpeakerUID
          }
        speaker = PTParticipant(name: activeSpeaker, image: UIImage())
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
        return .activeRemoteParticipant(speaker)
    }
    
    func stopReceivingAudio() {
        channelManager!.setActiveRemoteParticipant(nil, channelUUID: channelUUID!)
    }
    
    func channelManager(_ channelManager: PTChannelManager, didActivate audioSession: AVAudioSession) {
        print("didActivate")
        if isTransmiting {
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
                try audioSession.setActive(true)
            } catch {
                print("Can not setup the Recording")
            }
            
            let userId = AuthService.shared.user?.uid
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("\(userId!).aac")
            print("recorded: ", fileName)
            
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
                DispatchQueue.main.async{
                    self.status = "Start Speaking"
                  }
            } catch {
                print("Failed to Setup the Recording")
            }
        } else {
            let storage = Storage.storage()
            
            let storageRef = storage.reference()
            let voiceRef = storageRef.child("voice/\(speakerUID).aac")
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("\(speakerUID).aac")
            
            let downloadTask = voiceRef.write(toFile: fileName) { url, error in
                if let error = error {
                    self.stopReceivingAudio()
                } else {
                    print("playing: ", fileName)
                    
                    do {
                        try audioSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
                        try audioSession.setActive(true)
                    } catch {
                        print("Playing failed in Device")
                        self.stopReceivingAudio()
                    }
                    
                    do {
                        let data = try Data(contentsOf: fileName)
                        self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: "aac")
                        self.audioPlayer!.prepareToPlay()
                        self.audioPlayer!.play()
                        self.audioPlayer!.delegate = self
                    } catch {
                        print("Playing Failed")
                        print(error)
                        self.stopReceivingAudio()
                        DispatchQueue.main.async{
                            self.isPlaying = false
                          }
                    }
                }
            }
        }
    }
    
    func channelManager(_ channelManager: PTChannelManager, didDeactivate audioSession: AVAudioSession) {
        if isTransmiting {
            DispatchQueue.main.async{
                self.status = "Hold to Talk"
              }
            recorder.stop()
            
            let storage = Storage.storage()
            
            let storageRef = storage.reference()
            let userId = AuthService.shared.user?.uid
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("\(userId!).aac")
            
            let voiceRef = storageRef.child("voice/\(userId!).aac")
            
            voiceRef.putFile(from: fileName, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    self.isTransmiting = false
                    print("eer: ", error)
                    return
                }
                Task {
                    try? await PTTService.shared.sendPTTNotification()
                }
                self.isTransmiting = false
            }
        }
    }
    
    
    func leaveChannel() {
        print("leaveChannel")
        channelManager?.leaveChannel(channelUUID: channelUUID!)
    }
    
    
    func setupChannelManager() async throws {
        print("setupChannelManager")
        do {
            channelManager = try await PTChannelManager.channelManager(delegate: self,
                                                                       restorationDelegate: self)
        } catch {
            print("Error info: \(error)")
        }
    }
    
    func requestJoinChannel() {
        print("requestJoinChannel")
        if channelManager != nil {
            channelManager!.requestJoinChannel(channelUUID: channelUUID!,
                                               descriptor: channelDescriptor)
        }
    }
    
    func requestBeginTransmitting() {
        print("requestBeginTransmitting")
        channelManager!.requestBeginTransmitting(channelUUID: channelUUID!)
    }
    
    func stopTransmitting() {
        print("stopTransmitting")
        channelManager!.stopTransmitting(channelUUID: channelUUID!)
        DispatchQueue.main.async{
            self.status = "Hold to Talk"
          }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopReceivingAudio()
        DispatchQueue.main.async{
            self.isPlaying = false
          }
    }
}
