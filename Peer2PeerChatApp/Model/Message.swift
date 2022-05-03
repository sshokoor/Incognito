//
//  Message.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import Foundation
import SwiftUI

struct Message: Identifiable {
    let id: String
    let topicId: String
    let topicTitle: String
    let topicColor: Color
    let topicImage: String
    let userId: String
    let userName: String
    let userImage: String
    let message: String
    let date: String
    let time: String
}
