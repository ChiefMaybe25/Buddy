//
//  BUDDYApp.swift
//  BUDDY
//
//  Created by Mac on 7/1/25.
//

import SwiftUI
import AVFoundation
import Speech

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

// 1. Add ChatMessage struct
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
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
    @State private var isThinking: Bool = false
    @State private var bob: Bool = false
    @State private var buddyMood: String = "😊"
    @State private var chatHistory: [ChatMessage] = []
    @State private var isRecording: Bool = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background gradient for a soft, techy feel
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBlue).opacity(0.15), Color(.systemTeal).opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 28) {
                        // Header with avatar and welcome
                        VStack(spacing: 8) {
                            // Animated buddy avatar with vibrant green glow when thinking
                            ZStack {
                                if isThinking {
                                    Circle()
                                        .fill(Color.green.opacity(0.35))
                                        .frame(width: 120, height: 120)
                                        .blur(radius: 18)
                                    Circle()
                                        .fill(Color.green.opacity(0.25))
                                        .frame(width: 140, height: 140)
                                        .blur(radius: 32)
                                    Circle()
                                        .fill(Color.green.opacity(0.18))
                                        .frame(width: 170, height: 170)
                                        .blur(radius: 48)
                                }
                                Image("buddy_avatar")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                                    .shadow(radius: 8)
                                    .offset(y: bob ? -6 : 6)
                                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: bob)
                            }
                            .onAppear { bob = true }

                            // Glowing bubble for thinking message
                            if isThinking {
                                ZStack {
                                    Capsule()
                                        .fill(Color.green.opacity(0.18))
                                        .frame(height: 38)
                                        .blur(radius: 2)
                                    Capsule()
                                        .fill(Color.green.opacity(0.28))
                                        .frame(height: 38)
                                        .blur(radius: 8)
                                    Text("Please wait while I am thinking...")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 8)
                                }
                                .padding(.top, 2)
                                .transition(.opacity)
                            }

                            Text("B.U.D.D.Y.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.label))
                            Text("Your friendly AI companion")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Mood: \(buddyMood)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 24)
                        .animation(.easeInOut, value: isThinking)

                        // 3. Chat Card with scrollable history
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Chat with B.U.D.D.Y.")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.bottom, 2)

                            // Chat history scrollable list
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(chatHistory) { message in
                                        if message.isUser {
                                            ChatBubble(text: message.text, isUser: true)
                                                .id(message.id)
                                        } else {
                                            // BUDDY message with replay button
                                            HStack(alignment: .center, spacing: 8) {
                                                ChatBubble(text: message.text, isUser: false)
                                                    .id(message.id)
                                                Button(action: {
                                                    speak(text: message.text)
                                                }) {
                                                    Image(systemName: "arrow.triangle.2.circlepath")
                                                        .foregroundColor(.blue)
                                                        .padding(6)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .help("Replay BUDDY's message")
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 260)

                            HStack {
                                TextField("Say something...", text: $chatPrompt)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 6)
                                Button(action: {
                                    sendPrompt(scrollProxy: scrollProxy)
                                }) {
                                    if isChatLoading {
                                        ProgressView()
                                    } else {
                                        Text("Send")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .disabled(isChatLoading || chatPrompt.isEmpty)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isChatLoading || chatPrompt.isEmpty ? Color.gray.opacity(0.3) : Color.green.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                // Microphone button
                                Button(action: {
                                    if isRecording {
                                        stopRecording()
                                    } else {
                                        requestSpeechAuthAndStart()
                                    }
                                }) {
                                    Image(systemName: isRecording ? "mic.fill" : "mic")
                                        .foregroundColor(isRecording ? .red : .blue)
                                        .padding(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help(isRecording ? "Stop Recording" : "Speak to BUDDY")
                            }
                            if let chatError = chatError {
                                Text(chatError)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .shadow(radius: 4)

                        // Image Generator Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Image Generator")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.bottom, 2)
                            Text("What should I draw for you today?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack {
                                TextField("Describe your image...", text: $imagePrompt)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 6)
                                Button(action: generateImage) {
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        Text("Generate")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .disabled(isLoading || imagePrompt.isEmpty)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isLoading || imagePrompt.isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .shadow(radius: 4)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
                .onChange(of: chatHistory.count) {
                    // Scroll to the last message when a new one is added
                    if let last = chatHistory.last {
                        withAnimation {
                            scrollProxy.scrollTo(last.id, anchor: .bottom)
                        }
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
        }
    }

    // Chat bubble view
    struct ChatBubble: View {
        let text: String
        let isUser: Bool

        var body: some View {
            HStack {
                if isUser { Spacer() }
                Text(text)
                    .padding(12)
                    .background(isUser ? Color.green.opacity(0.2) : Color.blue.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(14)
                    .frame(maxWidth: 260, alignment: isUser ? .trailing : .leading)
                if !isUser { Spacer() }
            }
            .padding(isUser ? .leading : .trailing, 40)
        }
    }

    // 4. Update sendPrompt to use chatHistory and speak BUDDY's reply
    func sendPrompt(scrollProxy: ScrollViewProxy) {
        guard !chatPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = ChatMessage(text: chatPrompt, isUser: true)
        chatHistory.append(userMessage)
        let promptToSend = chatPrompt
        chatPrompt = ""
        isChatLoading = true
        isThinking = true
        chatError = nil
        chatResponse = ""
        guard let url = URL(string: "http://192.168.1.10:8000/chat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": promptToSend]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isChatLoading = false
                isThinking = false
                if let error = error {
                    chatError = error.localizedDescription
                    return
                }
                guard let data = data,
                      let result = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
                    chatError = "Invalid response from server."
                    return
                }
                let buddyMessage = ChatMessage(text: result.response, isUser: false)
                chatHistory.append(buddyMessage)
                speak(text: result.response) // Speak BUDDY's reply
                // Scroll to the last message
                if let last = chatHistory.last {
                    withAnimation {
                        scrollProxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }.resume()
    }

    // Apple TTS: Robotic but friendly
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        // Try to pick a "robotic" but friendly voice
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        utterance.pitchMultiplier = 1.3 // Higher pitch for friendliness
        utterance.rate = 0.45 // Moderate speed
        utterance.volume = 1.0
        // Force output to loudspeaker
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
        synthesizer.speak(utterance)
    }

    // Speech-to-text: Request permission and start
    func requestSpeechAuthAndStart() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                startRecording()
            } else {
                chatError = "Speech recognition not authorized."
            }
        }
    }

    // Start recording and transcribing
    func startRecording() {
        isRecording = true
        chatError = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            chatError = "Unable to create recognition request."
            isRecording = false
            return
        }
        // Set up audio session for recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            chatError = "Audio session setup failed."
            isRecording = false
            return
        }
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                chatPrompt = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            chatError = "Audio engine couldn't start."
            isRecording = false
        }
    }

    // Stop recording
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
    }

    func generateImage() {
        isLoading = true
        isThinking = true
        errorMessage = nil
        generatedImage = nil
        guard let url = URL(string: "http://192.168.1.10:8000/generate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": imagePrompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2000
        config.timeoutIntervalForResource = 2000
        let session = URLSession(configuration: config)

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                isThinking = false
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
                   let urlString = jsonResponse["url"] as? String,
                   let imageUrl = URL(string: urlString),
                   let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    generatedImage = image
                    showImageModal = true
                    return
                } else if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let detail = jsonResponse["detail"] as? String {
                    errorMessage = "Server error: \(detail)"
                    return
                }

                errorMessage = "Failed to generate image. Please try again."
            }
        }.resume()
    }
}













