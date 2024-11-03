//
//  Cloud.swift
//  voter_guide
//
//  Created by Ash Bhat on 11/2/24.
//

import Foundation
import CoreLocation
import UIKit

class Cloud {
    static let connection = Cloud()
    var url = "https://aihack.replit.app"
}

extension Cloud {
    func chat(messages: [MessageStruct], completion: @escaping(MessageStruct?, Error?) -> Void) {
        let url = self.url + "/ai/chat"
        
        let message_dict_arr = messages.map({$0.dict})
        Request.shared.postRequest(data: ["messages": message_dict_arr, "tools": tools], to: URL(string: url)!) { response, error in
            print(response ?? "no response")
            if let response = response as? [String: Any] {
                let response = response["response"] as? [String: Any]
                let role = response?["role"] as? String
                let content = response?["content"] as? String
                if let function = response?["function"] as? [String: Any] {
                    let function_name = function["name"] as? String
                    let arguments = function["arguments"] as? String
                    
                    let jsonData = arguments?.data(using: .utf8)
                    let arguments_dict  = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any]
                    if let arguments_dict = arguments_dict {
                        completion(MessageStruct(role: role ?? "assistant", content: "", function: FunctionCallStruct(name: function_name ?? "", arguments: arguments_dict)), nil)
                    }
                    else {
                        completion(MessageStruct(role: role ?? "assistant", content: "", function: FunctionCallStruct(name: function_name ?? "", arguments: [:])), nil)
                    }
                }
                else {
                    completion(MessageStruct(role: role ?? "assistant", content: content ?? ""), nil)
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func processDriversLicense(image: UIImage, completion: @escaping(DriverIdInfo?, Error?) -> Void) {
        let url = self.url + "/ai/process"
        
        let prompt = """
        
        """
        
        Request.shared.postRequest(data: ["attachment": image.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? "", "request": prompt], to: URL(string: url)!) { response, error in
            print(response ?? "no response")
            if let response = response as? [String: Any] {
                print("response: ", response)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    
    func get_voting_places(address: String, completion: @escaping([PollLocationStruct], [PollLocationStruct], Error?) -> Void) {
        
        let address = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
        let url = "https://www.googleapis.com/civicinfo/v2/voterinfo?key=\(google_key)&address=\(address)&electionId=9000"
        Request.shared.getRequest(url: URL(string: url)!) { response, error in
            if let response = response as? [String: Any] {

                var earlyVoting: [PollLocationStruct] = []
                var locations: [PollLocationStruct] = []
                let early_voting = response["earlyVoteSites"] as? [[String: Any]] ?? []
                for location in early_voting {
                    let address = location["address"] as? [String: Any]
                    
                    let location_name = address?["locationName"] as? String
                    let line_1 = address?["line1"] as? String
                    let line_2 = address?["line2"] as? String
                    let city = address?["city"] as? String
                    let state = address?["state"] as? String
                    let zip = address?["zip"] as? String
                    
                    let full_address = "\(line_1 ?? "") \(line_2 ?? ""), \(city ?? "") \(state ?? ""), \(zip ?? "")"
                    print("full_address: ", full_address)
                    
                    
                    let pollingHours = location["pollingHours"] as? String
                    let startDate = location["startDate"] as? String
                    let endDate = location["endDate"] as? String
                    
                    let latitude = location["latitude"] as? Double
                    let longitude = location["longitude"] as? Double
                    
                    let location = CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
                    
                    let poll_location = PollLocationStruct(name: location_name ?? "", full_address: full_address, polling_hours: pollingHours ?? "N/A", location: location, startDate: startDate ?? "", endDate: endDate ?? "")
                    earlyVoting.append(poll_location)
                }
                
                let pollingLocation = response["pollingLocations"] as? [[String: Any]] ?? []
                for location in pollingLocation {
                    let notes = location["notes"] as? String
                    let address = location["address"] as? [String: Any]
                    
                    let location_name = address?["locationName"] as? String
                    let line_1 = address?["line1"] as? String
                    let line_2 = address?["line2"] as? String
                    let city = address?["city"] as? String
                    let state = address?["state"] as? String
                    let zip = address?["zip"] as? String
                    
                    let full_address = "\(line_1 ?? "") \(line_2 ?? ""), \(city ?? "") \(state ?? ""), \(zip ?? "")"
                    print("full_address: ", full_address)
                    
                    
                    let pollingHours = location["pollingHours"] as? String
                    let startDate = location["startDate"] as? String
                    let endDate = location["endDate"] as? String
                    
                    let latitude = location["latitude"] as? Double
                    let longitude = location["longitude"] as? Double
                    
                    let location = CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
                    
                    
                    let poll_location = PollLocationStruct(name: location_name ?? "", full_address: full_address, polling_hours: pollingHours ?? "N/A", location: location, startDate: startDate ?? "", endDate: endDate ?? "")
                    locations.append(poll_location)
                }
                completion(earlyVoting, locations, nil)
            }
            else {
                completion([], [], error)
            }
        }
    }
    
    func get_perplexity_response(query: String, completion: @escaping(String?, Error?) -> Void) {
        let payload: [String: String] = ["content": query]
        Request.shared.postRequest(data: payload, to: URL(string: self.url + "/ai/chat/perplexity")!) { response, error in
            if let response = response as? [String: Any], let message = response["message"] as? String {
                completion(message, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
}
