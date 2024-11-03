//
//  MessagingVC+Functions.swift
//  voter_guide
//
//  Created by Ash Bhat on 11/2/24.
//

import UIKit

extension MessagingVC {
    func get_voting_places(address: String) {
        print("address: ", address)
        
        Cloud.connection.get_voting_places(address: address) { early_voting, voting_places, error in

            var returnString = """
            Here are a few places you can go to vote:
            **Early Voting**:
            """
            for place in early_voting.prefix(3) {
                returnString = returnString + "\n**\(place.name)**\n\(place.full_address)\n\(place.polling_hours)\n\(place.startDate) – \(place.endDate)\n\n"
            }
            returnString += "**Election Day Voting**:"
            for place in voting_places.prefix(3) {
                returnString = returnString + "\n**\(place.name)**\n\(place.full_address)\n\(place.polling_hours)\n\(place.startDate) – \(place.endDate)\n\n"
            }
            
            let message = MessageStruct(role: "assistant", content: returnString)
            DispatchQueue.main.async {
                self.processMessage(message: message)
            }
        }
    }
    
    func make_online_query(query: String) {
        Cloud.connection.get_perplexity_response(query: query) { response, error in
            if let response = response {
                let message = MessageStruct(role: "assistant", content: response)
                DispatchQueue.main.async {
                    self.processMessage(message: message)
                }
            }
            else {
                let message = MessageStruct(role: "assistant", content: "I was unable to search for real time results.")
                DispatchQueue.main.async {
                    self.processMessage(message: message)
                }
            }
        }
    }
}
