//
//  SettingsView.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 31/10/2025
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Settings Section Enum

enum SettingsSection: String, CaseIterable, Identifiable {
    case getStarted = "Get Started"
    case general = "General"
    case shortcuts = "Shortcuts"
    case includedApps = "Included Apps"
    case excludedApps = "Excluded Apps"
    case about = "About"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .getStarted: return "star.fill"
        case .general: return "gearshape.fill"
        case .shortcuts: return "keyboard.fill"
        case .includedApps: return "app.badge.checkmark.fill"
        case .excludedApps: return "app.badge.fill"
        case .about: return "info.circle.fill"
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var selectedSection: SettingsSection = .getStarted
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List(SettingsSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    Label {
                        Text(section.rawValue)
                            .font(.system(size: 13, weight: .medium))
                    } icon: {
                        Image(systemName: section.icon)
                            .font(.system(size: 13))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationSplitViewColumnWidth(200)
            .listStyle(.sidebar)
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                    .help("Toggle Sidebar")
                }
            }
        } detail: {
            // Detail View
            ZStack {
                VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                    .ignoresSafeArea()

                detailView(for: selectedSection)
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(width: 700, height: 500)
    }

    @ViewBuilder
    private func detailView(for section: SettingsSection) -> some View {
        switch section {
        case .getStarted:
            GetStartedView()
        case .general:
            GeneralSettingsView(viewModel: viewModel)
        case .shortcuts:
            ShortcutsView(viewModel: viewModel)
        case .includedApps:
            IncludedAppsView(viewModel: viewModel)
        case .excludedApps:
            ExcludedAppsView(viewModel: viewModel)
        case .about:
            AboutView()
        }
    }

    private func toggleSidebar() {
        withAnimation {
            if columnVisibility == .all {
                columnVisibility = .detailOnly
            } else {
                columnVisibility = .all
            }
        }
    }
}

// MARK: - Settings Section Component

struct SettingsSectionComponent<Content: View>: View {
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

// MARK: - Get Started View

struct GetStartedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to EasyQuit")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Quit applications with ease")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "keyboard.fill",
                        title: "Set up your shortcut",
                        description: "Configure a global keyboard shortcut to activate EasyQuit",
                        accentColor: .blue
                    )

                    FeatureRow(
                        icon: "app.badge.fill",
                        title: "Exclude important apps",
                        description: "Protect critical applications from accidental closure",
                        accentColor: .green
                    )

                    FeatureRow(
                        icon: "bolt.fill",
                        title: "Optimize performance",
                        description: "Adjust update intervals to match your workflow",
                        accentColor: .orange
                    )
                }

                Spacer()
            }
            .padding(24)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(accentColor)
                .frame(width: 50, height: 50)
                .background(accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - General Settings View

struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("General")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Text("Configure general application settings")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Performance Section
                SettingsSectionComponent(title: "Performance", icon: "gauge.with.dots.needle.bottom.50percent") {
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

                        Text("How often EasyQuit updates the list of running applications")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
    }
}

// MARK: - Shortcuts View

struct ShortcutsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shortcuts")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Text("Configure keyboard shortcuts")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Keyboard Shortcut Section
                SettingsSectionComponent(title: "Global Shortcut", icon: "keyboard") {
                    VStack(alignment: .leading, spacing: 12) {
                        ShortcutRecorderView(shortcut: $viewModel.globalShortcut)

                        Text("Press the key combination you want to use to activate EasyQuit")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
    }
}

// MARK: - Excluded Apps View

struct IncludedAppsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Included Apps")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Text("Background applications that should appear in EasyQuit")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Background Applications")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Button(action: selectAppFromFinder) {
                            Label("Add App", systemImage: "plus.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.borderless)
                    }

                    if viewModel.includedApps.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "app.badge.checkmark")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No included apps")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Text("Add background applications that you want to see in EasyQuit")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.includedApps), id: \.self) { bundleId in
                                AppRowView(bundleId: bundleId) {
                                    viewModel.removeIncludedApp(bundleId)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        }
                }

                Spacer()
            }
            .padding(24)
        }
    }

    private func selectAppFromFinder() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Application"
        openPanel.message = "Choose an application to include in EasyQuit"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [.application]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")

        openPanel.begin { response in
            guard response == .OK,
                  let url = openPanel.url,
                  let bundle = Bundle(url: url),
                  let bundleId = bundle.bundleIdentifier else {
                return
            }

            viewModel.addIncludedApp(bundleId)
        }
    }
}

struct AppRowView: View {
    let bundleId: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: appURL.path))
                    .resizable()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "app.fill")
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId),
                   let appName = FileManager.default.displayName(atPath: appURL.path).components(separatedBy: ".").first {
                    Text(appName)
                        .font(.system(size: 13, weight: .medium))
                } else {
                    Text(bundleId)
                        .font(.system(size: 13, weight: .medium))
                }

                Text(bundleId)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

struct ExcludedAppsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Excluded Apps")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Text("Applications that won't appear in EasyQuit")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Protected Applications")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Button(action: selectAppFromFinder) {
                            Label("Add App", systemImage: "plus.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.borderless)
                    }

                    if viewModel.ignoredApps.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "app.badge.checkmark")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No excluded apps")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Text("Add applications that you want to protect from accidental closure")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.ignoredApps), id: \.self) { bundleId in
                                AppRowView(bundleId: bundleId) {
                                    viewModel.removeIgnoredApp(bundleId)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        }
                }

                Spacer()
            }
            .padding(24)
        }
    }

    private func selectAppFromFinder() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Application"
        openPanel.message = "Choose an application to exclude from EasyQuit"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [.application]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")

        openPanel.begin { response in
            guard response == .OK,
                  let url = openPanel.url,
                  let bundle = Bundle(url: url),
                  let bundleId = bundle.bundleIdentifier else {
                return
            }

            viewModel.addIgnoredApp(bundleId)
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "app.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)

                    VStack(spacing: 4) {
                        Text("EasyQuit")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("Version 1.0.0")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 32)

                VStack(spacing: 12) {
                    Text("A powerful and intuitive application manager for macOS")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Divider()
                        .padding(.vertical, 8)

                    VStack(spacing: 12) {
                        InfoRow(label: "Developer", value: "cipher-shad0w")
                        InfoRow(label: "Created", value: "2025")
                        InfoRow(label: "License", value: "MIT")
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(24)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13))
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
