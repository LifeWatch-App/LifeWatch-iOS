//
//  CLPlacemarkExt.swift
//  YTeam Watch App
//
//  Created by Kevin Sander Utomo on 01/11/23.
//

import Foundation
import Contacts
import CoreLocation

extension CLPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        let formatter = CNPostalAddressFormatter()
        let formattedString = formatter.string(from: postalAddress)
        let formattedAddressWithCommas = formattedString.replacingOccurrences(of: "\n", with: ", ")
        return formattedAddressWithCommas
    }
}
