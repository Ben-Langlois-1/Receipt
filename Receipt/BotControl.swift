//
//  BotOutput.swift
//  Receipt
//
//  Created by Benjamin Langlois on 3/25/26.
//

import Combine
import OpenAI
import SwiftUI

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}

class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    @AppStorage("chatBotPersonality") private var chatBotPersonality:
        Personalities = .normal

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

    static let personalityPrompts: [Personalities: String] = [
        .mean:
            "Respond to everything following these instructions: High-Pressure / Savage, use tough love to shame a users bad spending habits. Extrapolate spending events out when appropriate",
        .normal:
            "You are a helpful and neutral assistant. Extrapolate spending events out when appropriate",
        .nice:
            "You are warm, encouraging, and supportive. Extrapolate spending events out when appropriate",
        .smart:
            "You are highly analytical and precise in your responses. Extrapolate spending events out when appropriate",
    ]

    func getBotReply() {
        let currentPersonalityRaw =
            UserDefaults.standard.string(forKey: "chatBotPersonality")
            ?? "normal"
        let currentPersonality =
            Personalities(rawValue: currentPersonalityRaw) ?? .normal
        let systemPrompt =
            ChatController.personalityPrompts[currentPersonality]
            ?? "You are a helpful assistant."

        let systemMessage =
            Chat(
                role: .system,
                content: systemPrompt

            )

        openAI.chats(
            query: .init(
                model: .gpt3_5Turbo,
                messages: [systemMessage]
                    + self.messages.map {
                        Chat(
                            role: $0.isUser ? .user : .assistant,
                            content: $0.content
                        )
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
