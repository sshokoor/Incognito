//
//  Constants.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import Foundation
import SwiftUI

class Constant {
    static let INTROS = [
        Intro(
            image: "intro_1",
            title: "Register/Login",
            description: "Register your self in the app by providing personal details"
        ),
        Intro(
            image: "intro_2",
            title: "Topics",
            description: "Select topics according to your need and discuss about it"
        ),
        Intro(
            image: "intro_3",
            title: "Chat",
            description: "Share your idea with other people"
        ),
    ]
    
    static let TOPICS = [
        Topic(
            id: "T0",
            imageName: "politics",
            topicTitle: "Politics",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "8A6642")
        ),
        Topic(
            id: "T1",
            imageName: "business",
            topicTitle: "Business",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "1E2460")
        ),
        Topic(
            id: "T2",
            imageName: "technology",
            topicTitle: "Technology",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "B32428")
        ),
        Topic(
            id: "T3",
            imageName: "travel",
            topicTitle: "Travel",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "82898F")
        ),
        Topic(
            id: "T4",
            imageName: "food",
            topicTitle: "Food",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "025669")
        ),
        Topic(
            id: "T5",
            imageName: "sports",
            topicTitle: "Sports",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "8673A1")
        ),
        Topic(
            id: "T6",
            imageName: "opinion",
            topicTitle: "Opinion",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "999950")
        ),
        Topic(
            id: "T7",
            imageName: "news",
            topicTitle: "News",
            createDate: "Created On 9 Aug, 2021",
            color: Color(hex: "00BB2D")
        )
    ]

    static var messageData = true
}
