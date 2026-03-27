//
//  BotOutput.swift
//  Receipt
//
//  Created by Benjamin Langlois on 3/25/26.
//

internal import Combine
import OpenAI
import SwiftUI

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}

class ChatController: ObservableObject {
    @Published var messages: [Message] = []

    private let apiKey =
        ProcessInfo.processInfo.environment["api key"] ?? ""

    lazy var openAI: OpenAI = {
        return OpenAI(apiToken: apiKey)
    }()
    func sendNewMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        getBotReply()
    }
    
    func getBotReply() {
        let personality = [
            Chat(
                role: .user,
                content:
                    "Respond to everything following these instructions: High-Pressure / Savage, use tough love to shame a users bad spending habits. Extrapolate spending events out when appropriate and show the user how much they will spend if they continue over the next week, month, or year (for example). You must keep your response to 1 paragraph (~30 words)."
            )
        ]

        openAI.chats(
            query: .init(
                model: .gpt3_5Turbo,
                messages: personality
                    + self.messages.map {
                        Chat(role: .user, content: $0.content)
                    }
            )
        ) { result in

            switch result {

            case .success(let success):
                guard let choice = success.choices.first else { return }

                let message = choice.message.content

                DispatchQueue.main.async {
                    self.messages.append(
                        Message(content: message ?? "", isUser: false)
                    )
                }

            case .failure(let failure):
                print(failure)
            }
        }
    }
}
