# TaskBrain — Native iOS App (Swift & SwiftUI)

Aplikasi manajemen tugas standalone native iOS dengan integrasi **Hermes Agent & 9router AI**, didesain dengan estetika ultra-minimalis (Linear / shadcn spec) dan fitur **Native Voice-to-Task** (Apple Speech Recognition).

---

## ✨ Fitur Utama

- **Native SwiftUI (iOS 16+)**: Antarmuka responsif, performa tinggi, dan dark mode native.
- **🎙️ On-Device Voice-to-Text**: Menggunakan framework `Speech` bawaan Apple dengan locale bahasa Indonesia (`id-ID`). Cukup tap tombol mic dan bicara.
- **⚡ AI Brain Dump**: Tumpahkan unek-unek atau kalimat acak, AI (Qwen / Hermes Engine) otomatis membedah judul tugas, prioritas (🔴 Tinggi, 🟡 Sedang, 🟢 Rendah), kategori, dan deadline.
- **Bento Progress Bar**: Visualisasi persentase penyelesaian tugas hari ini dan deteksi tugas urgent.
- **Quick Task Bar**: Tambah tugas tunggal dalam 1 ketukan.
- **Swipe Actions & Edit Sheet**: Swipe untuk menghapus atau menandai selesai, tap untuk mengedit detail tugas.
- **Configurable Server**: Bekerja mulus melalui jaringan privat **Tailscale** (`http://100.101.36.81:8765`) atau **Cloudflare Tunnel**.
- **🔔 Telegram Integration**: Tombol pengujian untuk memicu reminder instan langsung ke bot Telegram.

---

## 🚀 Cara Menjalankan di Mac / Xcode

1. Clone repositori ini:
   ```bash
   git clone https://github.com/emsabiq-alt/TaskBrain-iOS.git
   cd TaskBrain-iOS
   ```
2. Buka project di Xcode:
   ```bash
   open TaskBrain.xcodeproj
   ```
3. Pilih target simulator (misal: iPhone 15 Pro) atau perangkat iPhone fisik Anda.
4. Tekan **Cmd + R** untuk menjalankan aplikasi.

---

## 🛠️ Arsitektur Kode

- `TaskBrain/TaskBrainApp.swift` — Entry point SwiftUI App.
- `TaskBrain/Models/TaskItem.swift` — Data model & struktur JSON Codable.
- `TaskBrain/Services/APIService.swift` — Koneksi REST API ke backend task-system.
- `TaskBrain/Services/SpeechRecognizer.swift` — Engine Speech Recognition Apple (`SFSpeechRecognizer`).
- `TaskBrain/Views/ContentView.swift` — Dashboard utama & task list.
- `TaskBrain/Views/BrainDumpSheet.swift` — Modal input suara & teks berantakan.
- `TaskBrain/Views/TaskRowView.swift` — Komponen kartu baris tugas & swipe gestures.
- `TaskBrain/Views/EditTaskSheet.swift` — Form modal edit detail tugas.
- `TaskBrain/Views/SettingsView.swift` — Pengaturan alamat server & tombol tes Telegram.
