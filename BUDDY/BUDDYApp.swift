//
//  BUDDYApp.swift
//  BUDDY
//
//  Created by Mac on 7/1/25.
//

import SwiftUI

struct HealthResponse: Decodable {
    let status: String
    let message: String
}

struct ChatResponse: Decodable {
    let response: String
}

@main
struct BUDDYApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var chatPrompt: String = ""
    @State private var imagePrompt: String = ""
    @State private var isLoading: Bool = false
    @State private var generatedImage: UIImage? = nil
    @State private var showImageModal: Bool = false
    @State private var errorMessage: String? = nil
    @State private var chatResponse: String = ""
    @State private var isChatLoading: Bool = false
    @State private var chatError: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            Text("B.U.D.D.Y Assistant")
                .font(.title)
                .fontWeight(.bold)
            
            // Chat Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Chat with LLM")
                    .font(.headline)
                TextField("Enter your prompt...", text: $chatPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: sendPrompt) {
                    if isChatLoading {
                        ProgressView()
                    } else {
                        Text("Send to LLM")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(isChatLoading || chatPrompt.isEmpty)
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                if let chatError = chatError {
                    Text(chatError)
                        .foregroundColor(.red)
                }
                if !chatResponse.isEmpty {
                    ScrollView {
                        Text(chatResponse)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 150)
                }
            }
            .padding(.bottom, 20)
            
            Divider()
            
            // Image Generation Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Image Generator")
                    .font(.headline)
                TextField("Enter your image prompt...", text: $imagePrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: generateImage) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Generate Image")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(isLoading || imagePrompt.isEmpty)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showImageModal) {
            if let image = generatedImage {
                VStack {
                    Text("Generated Image")
                        .font(.headline)
                        .padding()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Button("Close") {
                        showImageModal = false
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
    
    func sendPrompt() {
        isChatLoading = true
        chatError = nil
        chatResponse = ""
        guard let url = URL(string: "http://localhost:8000/chat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": chatPrompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isChatLoading = false
                if let error = error {
                    chatError = error.localizedDescription
                    return
                }
                guard let data = data,
                      let result = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
                    chatError = "Invalid response from server."
                    return
                }
                chatResponse = result.response
            }
        }.resume()
    }
    
    func generateImage() {
        isLoading = true
        errorMessage = nil
        generatedImage = nil
        guard let url = URL(string: "http://localhost:8000/generate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": imagePrompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    errorMessage = "No data received from server."
                    return
                }
                
                // Try to parse as JSON first (in case of error response)
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let detail = jsonResponse["detail"] as? String {
                    errorMessage = "Server error: \(detail)"
                    return
                }
                
                // Try to load as image
                if let image = UIImage(data: data) {
                    generatedImage = image
                    showImageModal = true
                } else {
                    errorMessage = "Failed to generate image. Please try again."
                }
            }
        }.resume()
    }
}
