import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIService

    @AppStorage("server_url") private var serverURL: String = "http://100.101.36.81:8765"
    @State private var reminderStatus: String?
    @State private var isSending: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Koneksi Backend Server"), footer: Text("Gunakan IP Tailscale (http://100.101.36.81:8765) atau Cloudflare Tunnel URL.")) {
                    TextField("Server URL", text: $serverURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Integrasi Bot Telegram")) {
                    Button(action: triggerReminder) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.indigo)
                            Text("Kirim Reminder ke Telegram Sekarang")
                            Spacer()
                            if isSending {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSending)

                    if let status = reminderStatus {
                        Text(status)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Tentang Aplikasi")) {
                    HStack {
                        Text("Versi")
                        Spacer()
                        Text("1.0.0 Native Swift")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Engine")
                        Spacer()
                        Text("Hermes Agent & 9router")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Selesai") {
                        Task { await api.fetchTasks() }
                        dismiss()
                    }
                }
            }
        }
    }

    private func triggerReminder() {
        isSending = true
        reminderStatus = nil
        Task {
            let ok = await api.triggerTelegramReminder()
            isSending = false
            reminderStatus = ok ? "✅ Berhasil dikirim ke Telegram" : "❌ Gagal menghubungi server"
        }
    }
}
