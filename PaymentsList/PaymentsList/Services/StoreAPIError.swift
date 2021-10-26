//
//  StoreAPIError.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import Foundation

enum StoreAPIError: Error, LocalizedError {
    case urlError(URLError)
    case responseError(Int)
    case decodingError(DecodingError)
    case authorizationError
    case genericError
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .responseError(let status):
            return "Bad response code: \(status)"
        case .authorizationError:
            return "User authorization failed"
        case .genericError:
            return "An unknown error has been occured"
        }
    }
}
