//
//  ContentView.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    @FocusState private var isSearchFocused: Bool
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search apps...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .onSubmit {
                        // When Enter is pressed in search, focus on apps
                        isSearchFocused = false
                        selectedIndex = 0
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // App Grid (Icon only) - Shows 6 apps at once
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.fixed(80), spacing: 12),
                        GridItem(.fixed(80), spacing: 12),
                        GridItem(.fixed(80), spacing: 12)
                    ], spacing: 12) {
                        ForEach(Array(viewModel.filteredApps.enumerated()), id: \.element.id) { index, app in
                            AppRow(
                                app: app,
                                isSelected: !isSearchFocused && index == selectedIndex,
                                onQuit: { force in
                                    viewModel.quitApp(app, force: force)
                                },
                                onRestart: {
                                    viewModel.restartApp(app)
                                },
                                onShowInFinder: {
                                    viewModel.showInFinder(app)
                                },
                                onIgnore: {
                                    viewModel.ignoreApp(app)
                                }
                            )
                            .id(index)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.filteredApps.count)
                    .padding(16)
                }
                .background(Color(NSColor.windowBackgroundColor))
                .onChange(of: selectedIndex) { _, newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
        }
        .onAppear {
            isSearchFocused = true
        }
        .onKeyPress(.upArrow) {
            handleArrowKey(direction: .up)
            return .handled
        }
        .onKeyPress(.downArrow) {
            handleArrowKey(direction: .down)
            return .handled
        }
        .onKeyPress(.leftArrow) {
            handleArrowKey(direction: .left)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            handleArrowKey(direction: .right)
            return .handled
        }
        .onKeyPress(.return) {
            handleReturn()
            return .handled
        }
        .onKeyPress(.escape) {
            if !isSearchFocused {
                isSearchFocused = true
                return .handled
            }
            return .ignored
        }
    }

    private func handleArrowKey(direction: ArrowDirection) {
        guard !viewModel.filteredApps.isEmpty else { return }

        // If in search field, move to apps
        if isSearchFocused {
            isSearchFocused = false
            selectedIndex = 0
            return
        }

        let columns = 3
        let maxIndex = viewModel.filteredApps.count - 1

        switch direction {
        case .up:
            selectedIndex = max(0, selectedIndex - columns)
        case .down:
            selectedIndex = min(maxIndex, selectedIndex + columns)
        case .left:
            selectedIndex = max(0, selectedIndex - 1)
        case .right:
            selectedIndex = min(maxIndex, selectedIndex + 1)
        }
    }

    private func handleReturn() {
        guard !isSearchFocused,
              !viewModel.filteredApps.isEmpty,
              selectedIndex < viewModel.filteredApps.count else {
            return
        }

        let app = viewModel.filteredApps[selectedIndex]
        viewModel.quitApp(app, force: false)
    }

    enum ArrowDirection {
        case up, down, left, right
    }
}

#Preview {
    ContentView()
}
