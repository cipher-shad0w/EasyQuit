//
//  SettingsView.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 31/10/2025
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // Liquid glass background effect
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                            Text("Configure EasyQuit")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    // Keyboard Shortcut Section
                    SettingsSection(title: "Keyboard", icon: "keyboard") {
                        ShortcutRecorderView(shortcut: $viewModel.globalShortcut)
                    }

                    // Performance Section
                    SettingsSection(title: "Performance", icon: "gauge.with.dots.needle.bottom.50percent") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Update Interval")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)

                            HStack {
                                Slider(value: $viewModel.updateInterval, in: 1...5, step: 1)
                                    .tint(.accentColor)
                                Text("\(Int(viewModel.updateInterval))s")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .frame(width: 30)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(20)
            }
        }
        .frame(width: 450, height: 350)
    }
}

// MARK: - Settings Section Component

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.primary)

            VStack(spacing: 0) {
                content
                    .padding(16)
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    }
            }
        }
    }
}

// MARK: - Visual Effect Blur

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(settingsManager: DIContainer.shared.settingsManager))
}
