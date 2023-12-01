//
//  AnalysisService.swift
//  YTeam
//
//  Created by Yap Justin on 02/12/23.
//

import Foundation

class AnalysisService {
    static let shared: AnalysisService = AnalysisService()
    
    @Published var analysisData: [Analysis] = []
    @Published var analysisResult: [Message] = []
    @Published var analysis: String = ""
    @Published var analysisDate: Date = Date()
    @Published var isLoadingAnalysis: Bool = false
    
    func resetAnalysis() {
        print("Reset called")
        analysisData = []
        analysisResult = []
        analysis = ""
        analysisDate = Date()
        isLoadingAnalysis = false
    }
}

