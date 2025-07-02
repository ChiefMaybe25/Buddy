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

@main
struct BUDDYApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var prompt: String = ""
    @State private var isLoading: Bool = false
    @State private var generatedImage: UIImage? = nil
    @State private var showImageModal: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Text("B.U.D.D.Y Image Generator")
                .font(.title)
                .fontWeight(.bold)
            TextField("Enter your prompt...", text: $prompt)
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
            .disabled(isLoading || prompt.isEmpty)
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
    }
    
    func generateImage() {
        isLoading = true
        errorMessage = nil
        generatedImage = nil
        guard let url = URL(string: "http://localhost:3001/api/generate-image") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": prompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data, let image = UIImage(data: data) {
                    generatedImage = image
                    showImageModal = true
                } else {
                    errorMessage = "Failed to generate image. Please try again."
                }
            }
        }.resume()
    }
}
