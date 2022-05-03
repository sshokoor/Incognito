//
//  PushNotificationSender.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import Foundation
import SwiftUI

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, sender_id: String, sender_name: String, sender_pic: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : "/topics/\(token)",
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["sender_id" : sender_id,"sender_name": sender_name, "sender_pic":sender_pic]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAQ8530LA:APA91bFm0PrzCikeNvqiafljJNg2DtB6GeMu6dupab-56Er3gkfbJohQmmnkf9yW66wPZ1IqLRShcjM-zmLzFIGhXdtn4ArBdcdd4OQJJgU4L7TQUkYqk8TSxfZXxVTPoiALKG42Jshl", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}


