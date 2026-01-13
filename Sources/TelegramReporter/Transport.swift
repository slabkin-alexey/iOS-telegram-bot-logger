//
//  Transport.swift
//

import Foundation

enum Transport {
    static func send(_ text: String, using cfg: Config) async throws {
        let url = URL(string: "https://api.telegram.org/bot\(cfg.token)/sendMessage")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "chat_id": cfg.chatID,
            "text": text,
            "disable_web_page_preview": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
