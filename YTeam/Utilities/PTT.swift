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

class PTT: NSObject, PTChannelManagerDelegate, PTChannelRestorationDelegate {
    static let shared = PTT()
    var channelManager: PTChannelManager? = nil
    var channelUUID = UUID()
    var channelDescriptor = PTChannelDescriptor(name: "Awesome Crew", image: UIImage())
    
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        return channelDescriptor
    }
    
    func channelManager(_ channelManager: PTChannelManager, didJoinChannel channelUUID: UUID, reason: PTChannelJoinReason) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, didLeaveChannel channelUUID: UUID, reason: PTChannelLeaveReason) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
        
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
        channelManager!.setActiveRemoteParticipant(nil, channelUUID: channelUUID)
    }
    
    func channelManager(_ channelManager: PTChannelManager, didActivate audioSession: AVAudioSession) {
        
    }
    
    func channelManager(_ channelManager: PTChannelManager, didDeactivate audioSession: AVAudioSession) {
        
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
        channelManager!.requestJoinChannel(channelUUID: channelUUID,
                                          descriptor: channelDescriptor)
    }
}
