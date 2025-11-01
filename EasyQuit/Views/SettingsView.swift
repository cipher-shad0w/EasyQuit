//
//  SettingsView.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 31/10/2025
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    @AppStorage("showForceQuitWarning") private var showForceQuitWarning: Bool = true
    @AppStorage("showMultipleQuitWarning") private var showMultipleQuitWarning: Bool = true
    @AppStorage("hideSystemApps") private var hideSystemApps: Bool = true
    @AppStorage("compactView") private var compactView: Bool = false
    @AppStorage("showBackgroundApps") private var showBackgroundApps: Bool = false

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

                    // Behavior Section
                    SettingsSection(title: "Behavior", icon: "hand.tap") {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Default Action")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("Double-click behavior")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Picker("", selection: $viewModel.defaultAction) {
                                    ForEach(DefaultAction.allCases) { action in
                                        Text(action.rawValue)
                                            .tag(action)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }

                            Divider()

                            SettingsToggle(
                                title: "Hide System Apps",
                                description: "Don't show Finder, etc.",
                                icon: "shield.checkered",
                                isOn: $hideSystemApps
                            )

                            Divider()

                            SettingsToggle(
                                title: "Show Background Apps",
                                description: "Include apps without icons",
                                icon: "app.badge",
                                isOn: $showBackgroundApps
                            )
                            .onChange(of: showBackgroundApps) { newValue in
                                viewModel.updateShowBackgroundApps(newValue)
                            }
                        }
                    }

                    // Warnings Section
                    SettingsSection(title: "Warnings", icon: "exclamationmark.triangle") {
                        VStack(spacing: 16) {
                            SettingsToggle(
                                title: "Force Quit Warning",
                                description: "Confirm before force quitting",
                                icon: "exclamationmark.circle",
                                isOn: $showForceQuitWarning
                            )

                            Divider()

                            SettingsToggle(
                                title: "Multiple Apps Warning",
                                description: "Confirm when quitting multiple apps",
                                icon: "square.stack.3d.up",
                                isOn: $showMultipleQuitWarning
                            )
                        }
                    }

                    // Appearance Section
                    SettingsSection(title: "Appearance", icon: "paintbrush") {
                        SettingsToggle(
                            title: "Compact View",
                            description: "Smaller app icons",
                            icon: "rectangle.compress.vertical",
                            isOn: $compactView
                        )
                    }

                    Spacer()
                }
                .padding(20)
            }
        }
        .frame(width: 450, height: 550)
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

// MARK: - Settings Toggle Component

struct SettingsToggle: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
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
