//
//  Messaging.swift
//  voter_guide
//
//  Created by Ash Bhat on 11/2/24.
//

import Foundation
import CoreLocation

enum MesssageActions {
    case upload_driver_id
}

struct FunctionCallStruct {
    var name: String
    var arguments: [String: Any]
}

struct MessageStruct {
    var id: String = UUID().uuidString
    var role: String
    var content: String
    var name: String? = nil
    var function: FunctionCallStruct? = nil
    var actions: [MesssageActions] = []
    var polling_locations: [PollLocationStruct] = []
    
    var dict: [String: Any] {
        if let name = name {
            return [
                "role": role,
                "content": content,
                "name": name
            ]
        }
        return [
            "role": role,
            "content": content,
        ]
    }
}

struct PollLocationStruct {
    var name: String
    var full_address: String
    var polling_hours: String
    var location: CLLocationCoordinate2D
    var startDate: String
    var endDate: String
    
    var stringRepresentation: String {
        return "{address: \(full_address), polling_hours: \(polling_hours), location_lat: \(location.latitude), location_lon: \(location.longitude), startDate: \(startDate), endDate: \(endDate) }"
    }
}


var tools = [
    [
        "type": "function",
        "function": [
                "name": "get_voting_places",
                "description": "Get voting location for a user",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "registered_address": [
                            "type": "string",
                            "description": "The registered address of the voter."
                        ]
                    ],
                    "required": ["registered_address"]
                ]
            ]
    ],
    [
        "type": "function",
        "function": [
                "name": "query_internet_for_realtime_results",
                "description": "Ask a question to an LLM connected to the internet for real time data.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "query": [
                            "type": "string",
                            "description": "The query being made."
                        ]
                    ],
                    "required": ["query"]
                ]
            ]
    ],
    [
        "type": "function",
        "function": [
                "name": "get_realtime_election_information",
                "description": "Ask a question to an LLM connected to the internet for real time data.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "query": [
                            "type": "string",
                            "description": "The query being made."
                        ]
                    ],
                    "required": ["query"]
                ]
            ]
    ],
]
