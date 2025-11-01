//
//  ContentView.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppListViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var selectedIndex: Int = 0
    private let keyboardHandler = KeyboardEventHandler()

    init(viewModel: AppListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // Invisible keyboard event handler
            KeyboardEventView(handler: keyboardHandler)
                .frame(width: 0, height: 0)

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
                            .id(app.id)
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
        }
        .onAppear {
            isSearchFocused = true
            setupKeyboardHandlers()
        }
    }

    private func setupKeyboardHandlers() {
        keyboardHandler.onUpArrow = {
            self.handleArrowKey(direction: .up)
        }
        keyboardHandler.onDownArrow = {
            self.handleArrowKey(direction: .down)
        }
        keyboardHandler.onLeftArrow = {
            self.handleArrowKey(direction: .left)
        }
        keyboardHandler.onRightArrow = {
            self.handleArrowKey(direction: .right)
        }
        keyboardHandler.onReturn = {
            self.handleReturn()
        }
        keyboardHandler.onEscape = {
            if !self.isSearchFocused {
                self.isSearchFocused = true
            }
        }
        keyboardHandler.shouldHandleEvent = { event in
            // Don't handle events if search is focused (except arrow keys to exit search)
            if self.isSearchFocused {
                // Allow arrow keys to move from search to grid
                return event.keyCode == 126 || event.keyCode == 125 ||
                       event.keyCode == 123 || event.keyCode == 124
            }
            return true
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
        let currentRow = selectedIndex / columns
        let currentCol = selectedIndex % columns

        switch direction {
        case .up:
            // Move up one row in the same column
            if currentRow > 0 {
                selectedIndex = max(0, selectedIndex - columns)
            } else {
                // Wrap to bottom row, same column
                let lastRow = maxIndex / columns
                let targetIndex = lastRow * columns + currentCol
                selectedIndex = min(maxIndex, targetIndex)
            }

        case .down:
            // Move down one row in the same column
            let nextRowIndex = selectedIndex + columns
            if nextRowIndex <= maxIndex {
                selectedIndex = nextRowIndex
            } else {
                // Wrap to top row, same column
                selectedIndex = currentCol
            }

        case .left:
            // Move left in the current row
            if currentCol > 0 {
                selectedIndex -= 1
            } else if selectedIndex > 0 {
                // At start of row (but not first item), wrap to end of previous row
                selectedIndex -= 1
            } else {
                // At first item, wrap to last item
                selectedIndex = maxIndex
            }

        case .right:
            // Move right in the current row
            if currentCol < columns - 1 && selectedIndex < maxIndex {
                selectedIndex += 1
            } else if selectedIndex < maxIndex {
                // At end of row, wrap to start of next row
                selectedIndex += 1
            } else {
                // At last item, wrap to first item
                selectedIndex = 0
            }
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

// MARK: - Keyboard Event Handling

class KeyboardEventHandler {
    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    var onLeftArrow: (() -> Void)?
    var onRightArrow: (() -> Void)?
    var onReturn: (() -> Void)?
    var onEscape: (() -> Void)?
    var shouldHandleEvent: ((NSEvent) -> Bool)?

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard shouldHandleEvent?(event) ?? true else { return false }

        switch event.keyCode {
        case 126: // Up arrow
            onUpArrow?()
            return true
        case 125: // Down arrow
            onDownArrow?()
            return true
        case 123: // Left arrow
            onLeftArrow?()
            return true
        case 124: // Right arrow
            onRightArrow?()
            return true
        case 36: // Return
            onReturn?()
            return true
        case 53: // Escape
            onEscape?()
            return true
        default:
            return false
        }
    }
}

struct KeyboardEventView: NSViewRepresentable {
    let handler: KeyboardEventHandler

    func makeNSView(context: Context) -> KeyEventNSView {
        let view = KeyEventNSView()
        view.keyHandler = handler
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyEventNSView, context: Context) {
        nsView.keyHandler = handler
    }
}

class KeyEventNSView: NSView {
    var keyHandler: KeyboardEventHandler?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        if !(keyHandler?.handleKeyDown(event) ?? false) {
            super.keyDown(with: event)
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }
}

#Preview {
    ContentView(viewModel: DIContainer.shared.makeAppListViewModel())
}
