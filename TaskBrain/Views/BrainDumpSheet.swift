import SwiftUI

struct BrainDumpSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIService
    @StateObject private var speech = SpeechRecognizer()

    @State private var rawText: String = ""
    @State private var isSubmitting: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Info banner
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.indigo)
                    Text("Tumpahkan unek-unek / catatan via suara atau ketik. AI merapikan otomatis.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)

                // Textarea
                ZStack(alignment: .topLeading) {
                    if rawText.isEmpty && !speech.isRecording {
                        Text("Contoh: besok jam 10 pagi wajib call Pak Eko bahas revisi video intro, trus kirim invoice ke Bu Lina, sama cek server...")
                            .font(.system(size: 15))
                            .foregroundColor(Color(white: 0.35))
                            .padding(.top, 10)
                            .padding(.leading, 12)
                    }

                    TextEditor(text: $rawText)
                        .font(.system(size: 15))
                        .scrollContentBackground(.hidden)
                        .background(Color(white: 0.08))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .frame(minHeight: 140)

                // Voice Recording Controls
                HStack(spacing: 16) {
                    Button(action: toggleSpeech) {
                        HStack(spacing: 8) {
                            Image(systemName: speech.isRecording ? "stop.circle.fill" : "mic.fill")
                                .font(.system(size: 16))
                            Text(speech.isRecording ? "Stop Bicara" : "Rekam Suara (ID)")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(speech.isRecording ? .red : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(speech.isRecording ? Color.red.opacity(0.15) : Color(white: 0.15))
                        .cornerRadius(10)
                    }

                    if !rawText.isEmpty {
                        Button("Hapus") {
                            rawText = ""
                            speech.reset()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                // Submit Button
                Button(action: submitText) {
                    HStack(spacing: 8) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "bolt.fill")
                        }
                        Text(isSubmitting ? "Sedang merapikan..." : "⚡ Rapikan Jadi Tasks")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting ? Color.gray.opacity(0.3) : Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(Color(white: 0.04).ignoresSafeArea())
            .navigationTitle("AI Brain Dump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        speech.stopRecording()
                        dismiss()
                    }
                }
            }
            .onChange(of: speech.transcript) { newTranscript in
                if !newTranscript.isEmpty {
                    rawText = newTranscript
                }
            }
        }
    }

    private func toggleSpeech() {
        if speech.isRecording {
            speech.stopRecording()
        } else {
            speech.startRecording()
        }
    }

    private func submitText() {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isSubmitting = true
        speech.stopRecording()

        Task {
            let success = await api.organizeRawText(text)
            isSubmitting = false
            if success {
                dismiss()
            }
        }
    }
}
