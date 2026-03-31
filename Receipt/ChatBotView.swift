//
//  ChatBotView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 3/23/26.
//

import SwiftData
import SwiftUI

struct ChatBotView: View {
    @Query var allGoals: [SpendingGoal]
    @Query(sort: \Expense.timeStamp, order: .reverse) var expenses: [Expense]
    
    @StateObject var chatController: ChatController = .init()
    @State var string: String = ""
    
    @AppStorage("chatBotPersonality") private var chatBotPersonality: Personalities = .normal

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                VStack {
                    Divider()
                    ScrollView {
                        ForEach(chatController.messages) { message in
                            MessageView(message: message)
                                .padding(5)
                                .id(message.id)
                        }
                    }
                    .onChange(of: chatController.messages.count) {
                        if let last = chatController.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }

                    Divider()

                    HStack {

                        TextField("Message...", text: $string, axis: .vertical)
                            .onSubmit {
                                sendMessage()
                            }
                            .padding(7)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)

                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane")
                        }
                    }
                    .padding()
                }

            }
            .navigationTitle("Chat with ReceiptBot")
            .toolbar {
                Button("Analyze recent spending", systemImage: "chart.line.uptrend.xyaxis.circle") {
                    let amount = expenses.last?.amount ?? 0
                    let formatted = amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
                    string = "Critique my most recent spending: I spent \(expenses.last?.amount != nil ? formatted : "unknown") on \(expenses.last?.timeStamp.formatted(date: .numeric, time: .shortened) ?? "unknown")"
                    sendMessage()
                }
            }
        }

    }

    func sendMessage() {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty { return }

        chatController.sendNewMessage(content: trimmed)
        string = ""
    }
}

struct MessageView: View {
    var message: Message

    var body: some View {
        HStack {

            if message.isUser {
                Spacer()
            }

            Text(message.content)
                .padding(12)
                .foregroundColor(.white)
                .background(message.isUser ? Color.blue : Color.gray)
                .cornerRadius(16)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: 300,
                    alignment: message.isUser ? .trailing : .leading
                )

            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    ChatBotView()
}
