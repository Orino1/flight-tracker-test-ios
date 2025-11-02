//
//  MicView.swift
//  testprotect
//
//  Created by orino on 31/10/2025.
//

import SwiftUI
import Foundation
import AVFoundation
import Speech

struct MicView: View {
    @State private var viewModel = SpeechToTextViewModel()

    // for now we would need what mode we are using
    enum SearchMode {
        case text
        case voice
    }

    @State private var searchMode: SearchMode = .voice
    @State private var placeHodler: String = "Search for a flight"
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var showMicAlert = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField(placeHodler, text: $text)
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(99)
                    .focused($isFocused)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: Color.white.opacity(0.3), radius: 2, x: -1, y: -1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    )
                    .onChange(of: isFocused) { oldValue, newValue in
                        if newValue {
                            if viewModel.model.isRecording {
                                viewModel.toggleRecording()
                            }
                            searchMode = .text
                        } else {
                            searchMode = .voice
                        }
                    }
                Circle()
                    .fill(Color.primary.opacity(1))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: searchMode == .text ? "magnifyingglass" : viewModel.model.isRecording ? "stop.circle" : "microphone.fill" )
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color(.systemBackground))
                    }
                    .onTapGesture {
                        switch searchMode {
                        case .text:
                            print("search via text is invoked here")
                        case .voice:
                            if let _ = viewModel.errorMessage {
                                showMicAlert = true
                            } else {
                                withAnimation { viewModel.toggleRecording() }
                            }
                        }
                    }
                    .alert("Microphone Access Required",
                           isPresented: $showMicAlert,
                           actions: {
                        Button("OK", role: .cancel) {}
                    },
                           message: {
                        Text("Please allow microphone access in Settings to use voice search.")
                    })
                if viewModel.model.isRecording {
                    Circle()
                        .fill(Color.primary.opacity(1))
                        .frame(width: 50, height: 50)
                        .overlay {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color(.systemBackground))
                        }
                        .onTapGesture {
                            // TODO: stop recording and go to next step
                            print("searched via a btn click here ")
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .onChange(of: viewModel.model.isRecording) { _, newValue in
                if newValue {
                    text = ""
                    placeHodler = "Listening"
                } else {
                    placeHodler = "Search for a flight"
                }
            }
            .onChange(of: viewModel.model.displayText) { _, newValue in
                if viewModel.model.isRecording {
                    text = newValue
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: text)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.model.isRecording)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Button(action: {
//                    viewModel.toggleRecording()
//                }) {
//                    VStack {
//                        Image(systemName: viewModel.model.isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                            .font(.system(size: 60))
//                            .foregroundColor(viewModel.model.isRecording ? .red : .blue)
//                        
//                        Text(viewModel.model.isRecording ? "Stop Recording" : "Start Recording")
//                            .font(.headline)
//                            .foregroundColor(viewModel.model.isRecording ? .red : .blue)
//                    }
//                }
//                .padding()
//
//                if viewModel.model.isRecording {
//                    HStack {
//                        Circle()
//                            .fill(Color.red)
//                            .frame(width: 10, height: 10)
//                            .scaleEffect(viewModel.model.isRecording ? 1.0 : 0.5)
//                            .animation(.easeInOut(duration: 0.5).repeatForever(), value: viewModel.model.isRecording)
//                        
//                        Text("Recording...")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 10) {
//                        if !viewModel.model.displayText.isEmpty {
//                            Text(viewModel.model.displayText)
//                                .font(.body)
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(10)
//                        } else {
//                            Text("Tap the microphone to start recording...")
//                                .font(.body)
//                                .foregroundColor(.secondary)
//                                .padding()
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                if let errorMessage = viewModel.errorMessage {
//                    Text(errorMessage)
//                        .font(.caption)
//                        .foregroundColor(.red)
//                        .padding(.horizontal)
//                }
//
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Speech to Text")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Clear") {
//                        viewModel.clearTranscript()
//                    }
//                    .disabled(viewModel.model.displayText.isEmpty)
//                }
//            }
//        }
//    }
}

#Preview {
    MicView()
}

// MARK: - For now its raw ;)


class AudioManager {

    // 1.
    private let audioEngine = AVAudioEngine()
    private var audioTapInstalled = false

    // 2.
    func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    // 3.
    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // 4.
    func startAudioStream(onBuffer: @escaping (AVAudioPCMBuffer) -> Void) throws {
        guard !audioTapInstalled else { return }
        
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: audioEngine.inputNode.outputFormat(forBus: 0)
        ) { buffer, _ in
            onBuffer(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        audioTapInstalled = true
    }

    // 5.
    func stopAudioStream() {
        guard audioTapInstalled else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioTapInstalled = false
    }
}

class BufferConverter {

    // 1.
    enum Error: Swift.Error {
        case failedToCreateConverter
        case failedToCreateConversionBuffer
        case conversionFailed(NSError?)
    }

    // 2.
    private var converter: AVAudioConverter?

    // 3.
    func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let inputFormat = buffer.format
        guard inputFormat != format else {
            return buffer
        }
        
        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: inputFormat, to: format)
            converter?.primeMethod = .none
        }
        
        guard let converter = converter else {
            throw Error.failedToCreateConverter
        }
        
        let sampleRateRatio = converter.outputFormat.sampleRate / converter.inputFormat.sampleRate
        let scaledInputFrameLength = Double(buffer.frameLength) * sampleRateRatio
        let frameCapacity = AVAudioFrameCount(scaledInputFrameLength.rounded(.up))
        guard let conversionBuffer = AVAudioPCMBuffer(pcmFormat: converter.outputFormat, frameCapacity: frameCapacity) else {
            throw Error.failedToCreateConversionBuffer
        }
        
        var nsError: NSError?
        var bufferProcessed = false
        
        let status = converter.convert(to: conversionBuffer, error: &nsError) { packetCount, inputStatusPointer in
            defer { bufferProcessed = true }
            inputStatusPointer.pointee = bufferProcessed ? .noDataNow : .haveData
            return bufferProcessed ? nil : buffer
        }
        
        guard status != .error else {
            throw Error.conversionFailed(nsError)
        }
        
        return conversionBuffer
    }
}

class TranscriptionManager {

    // 1.
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var recognizerTask: Task<(), Error>?
    private var analyzerFormat: AVAudioFormat?
    private var converter = BufferConverter()

    // 2.
    func requestSpeechPermission() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return status == .authorized
    }

    // 3.
    func startTranscription(onResult: @escaping (String, Bool) -> Void) async throws {
        transcriber = SpeechTranscriber(
            locale: Locale.current,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: []
        )
        analyzer = SpeechAnalyzer(modules: [transcriber!])
        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber!])
        
        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        self.inputBuilder = inputBuilder
        
        recognizerTask = Task {
            for try await result in transcriber!.results {
                let text = String(result.text.characters)
                onResult(text, result.isFinal)
            }
        }
        
        try await analyzer?.start(inputSequence: inputSequence)
    }

    // 4.
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) throws {
        guard let inputBuilder, let analyzerFormat else { return }
        let converted = try converter.convertBuffer(buffer, to: analyzerFormat)
        inputBuilder.yield(AnalyzerInput(buffer: converted))
    }

    // 5.
    func stopTranscription() async {
        inputBuilder?.finish()
        try? await analyzer?.finalizeAndFinishThroughEndOfInput()
        recognizerTask?.cancel()
        recognizerTask = nil
    }
}

struct TranscriptionModel {
    var finalizedText: String = ""
    var currentText: String = ""
    var isRecording: Bool = false
    
    var displayText: String {
        return finalizedText + currentText
    }
}

@MainActor
@Observable
class SpeechToTextViewModel {

    // 1.
    private(set) var model = TranscriptionModel()
    private(set) var errorMessage: String?
    private let audioManager = AudioManager()
    private let transcriptionManager = TranscriptionManager()


    // 2.
    private func requestPermissions() async -> Bool {
        let speechPermission = await transcriptionManager.requestSpeechPermission()
        let micPermission = await audioManager.requestMicrophonePermission()
        return speechPermission && micPermission
    }
    
    // 3.
    func toggleRecording() {
        if model.isRecording {
            Task { await stopRecording() }
        } else {
            Task { await startRecording() }
        }
    }

    // 4.
    func clearTranscript() {
        model.finalizedText = ""
        model.currentText = ""
        errorMessage = nil
    }

    // 5.
    private func startRecording() async {
        clearTranscript()
        guard await requestPermissions() else {
            errorMessage = "Permissions not granted"
            return
        }
        
        do {
            try audioManager.setupAudioSession()
            
            try await transcriptionManager.startTranscription { [weak self] text, isFinal in
                Task { @MainActor in
                    guard let self = self else { return }
                    if isFinal {
                        self.model.finalizedText += text + " "
                        self.model.currentText = ""
                    } else {
                        self.model.currentText = text
                    }
                }
            }
            
            try audioManager.startAudioStream { [weak self] buffer in
                try? self?.transcriptionManager.processAudioBuffer(buffer)
            }
            
            model.isRecording = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 6.
    private func stopRecording() async {
        audioManager.stopAudioStream()
        await transcriptionManager.stopTranscription()
        model.isRecording = false
    }

}
