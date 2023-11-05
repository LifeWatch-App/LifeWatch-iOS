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
    var channelDescriptor = PTChannelDescriptor(name: "Awesome Crew", image: UIImage())
    var recorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var isTransmiting = false
    var speaker = PTParticipant(name: "-", image: UIImage())
    
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        return channelDescriptor
    }
    
    func channelManager(_ channelManager: PTChannelManager, didJoinChannel channelUUID: UUID, reason: PTChannelJoinReason) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, didLeaveChannel channelUUID: UUID, reason: PTChannelLeaveReason) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
        print("didBeginTransmittingFrom")
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
        isTransmiting = true
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didEndTransmittingFrom source: PTChannelTransmitRequestSource) {
    }
    
    func channelManager(_ channelManager: PTChannelManager, receivedEphemeralPushToken pushToken: Data) {
        let pttToken = pushToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("PTT Token: ", pttToken)
        UserDefaults.standard.set(pttToken, forKey: "pttToken")
         
        if AuthService.shared.user != nil {
            if (pttToken != AuthService.shared.userData?.pttToken ?? "") {
                AuthService.shared.updatePTTToken(pttToken: pttToken)
            }
        }
    }
    
    func incomingPushResult(channelManager: PTChannelManager, channelUUID: UUID, pushPayload: [String : Any]) -> PTPushResult {
        print("payload received")
        guard let activeSpeaker = pushPayload["activeSpeaker"] as? String else {
            return .leaveChannel
        }
        print("payload received from: \(activeSpeaker)")
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
                
            } catch {
                print("Failed to Setup the Recording")
            }
        } else {
            let storage = Storage.storage()
            
            let storageRef = storage.reference()
            let voiceRef = storageRef.child("voice/\(speaker.name).aac")
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("\(speaker.name).aac")
            
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
                    }
                }
            }
        }
    }
    
    func channelManager(_ channelManager: PTChannelManager, didDeactivate audioSession: AVAudioSession) {
        if isTransmiting {
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
                    return
                }
                Task {
                    try? await PTTService.shared.sendPTTNotification()
                }
                self.isTransmiting = false
            }
        }
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
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopReceivingAudio()
    }
}
