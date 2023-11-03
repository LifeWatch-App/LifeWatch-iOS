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

class PTT: NSObject, PTChannelManagerDelegate, PTChannelRestorationDelegate {
    static let shared = PTT()
    var channelManager: PTChannelManager? = nil
    var channelUUID = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")
    var channelDescriptor = PTChannelDescriptor(name: "Awesome Crew", image: UIImage())
    var recorder : AVAudioRecorder!
    var isTransmiting = false
    
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        return channelDescriptor
    }
    
    func channelManager(_ channelManager: PTChannelManager, didJoinChannel channelUUID: UUID, reason: PTChannelJoinReason) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, didLeaveChannel channelUUID: UUID, reason: PTChannelLeaveReason) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
        isTransmiting = true
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didEndTransmittingFrom source: PTChannelTransmitRequestSource) {
    }
    
    func channelManager(_ channelManager: PTChannelManager, receivedEphemeralPushToken pushToken: Data) {
        print("PTT Token: ", pushToken.map { String(format: "%02.2hhx", $0) }.joined())
    }
    
    func incomingPushResult(channelManager: PTChannelManager, channelUUID: UUID, pushPayload: [String : Any]) -> PTPushResult {
        print("payload received")
        guard let activeSpeaker = pushPayload["activeSpeaker"] as? String else {
               // If no active speaker is set, the only other valid operation
               // is to leave the channel
               return .leaveChannel
           }

           let participant = PTParticipant(name: activeSpeaker, image: UIImage())
           return .activeRemoteParticipant(participant)
    }
    
    func stopReceivingAudio() {
        channelManager!.setActiveRemoteParticipant(nil, channelUUID: channelUUID!)
    }
    
    func channelManager(_ channelManager: PTChannelManager, didActivate audioSession: AVAudioSession) {
//        let recordingSession = AVAudioSession.sharedInstance()
        if isTransmiting {
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
            } catch {
                print("Can not setup the Recording")
            }
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("CO-Voice : test.aac")
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
            
        }
    }
    
    func channelManager(_ channelManager: PTChannelManager, didDeactivate audioSession: AVAudioSession) {
        if isTransmiting {
            recorder.stop()
            
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()

            // Create a storage reference from our storage service
            let storageRef = storage.reference()
                
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("CO-Voice : test.aac")

            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("voice/test.aac")

            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putFile(from: fileName, metadata: nil) { metadata, error in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
              riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
              }
            }
            
            isTransmiting = false
        } else {
            
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
        channelManager!.requestJoinChannel(channelUUID: channelUUID!,
                                          descriptor: channelDescriptor)
    }
    
    func requestBeginTransmitting() {
        print("requestBeginTransmitting")
        channelManager!.requestBeginTransmitting(channelUUID: channelUUID!)
    }
    
    func stopTransmitting() {
        print("stopTransmitting")
        channelManager!.stopTransmitting(channelUUID: channelUUID!)
    }
}
