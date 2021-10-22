//
//  Payment.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import Foundation


public struct PaymentsResponse: Codable {
    public let success: String
    public let response: [Payment]
}

public struct Payment: Codable, Hashable {
    
    public let desc: String
    public let amount: Double
    public let currency: String?
    public let created: Int

    public init(from decoder: Decoder) throws {
        // Decode all fields and store them
        let container = try decoder.container(keyedBy: CodingKeys.self) // The compiler creates coding keys for each property, so as long as the keys are the same as the property names, we don't need to define our own enum.

        desc = try container.decode(String.self, forKey: .desc)
        do {
            amount = try container.decode(Double.self, forKey: .amount)
        } catch {
            // The check for a String and then cast it, this will throw if decoding fails
            if let typeValue = Double(try container.decode(String.self, forKey: .amount)) {
                amount = typeValue
            } else {
                // You may want to throw here if you don't want to default the value(in the case that it you can't have an optional).
                amount = 0
            }
        }
        do {
            currency = try container.decode(String.self, forKey: .currency)
        } catch {
            currency = nil
        }
        created = try container.decode(Int.self, forKey: .created)
        dump(self)
    }

}

// Where I can represent all the types that the JSON property can be.
enum DynamicJSONProperty: Codable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()

        // Decode the double
        do {
            let doubleVal = try container.decode(Double.self)
            self = .double(doubleVal)
        } catch DecodingError.typeMismatch {
            // Decode the string
            let stringVal = try container.decode(String.self)
            self = .string(stringVal)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}
