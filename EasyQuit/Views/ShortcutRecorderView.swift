//
//  ShortcutRecorderView.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 31/10/2025
//

import SwiftUI

/// A view that allows users to record keyboard shortcuts
struct ShortcutRecorderView: View {
    @Binding var shortcut: KeyboardShortcut?
    @State private var isRecording = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Global Shortcut")
                    .font(.system(size: 13, weight: .medium))
                Text("Activate EasyQuit from anywhere")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                ShortcutRecorderButton(
                    shortcut: $shortcut,
                    isRecording: $isRecording
                )

                if shortcut != nil {
                    Button(action: {
                        shortcut = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Clear shortcut")
                }
            }
        }
    }
}

/// The actual button that records the keyboard shortcut
private struct ShortcutRecorderButton: View {
    @Binding var shortcut: KeyboardShortcut?
    @Binding var isRecording: Bool

    var body: some View {
        ShortcutRecorderNSView(
            shortcut: $shortcut,
            isRecording: $isRecording
        )
        .frame(width: 120, height: 24)
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(isRecording ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
        }
    }
}

/// NSViewRepresentable wrapper for the shortcut recorder
private struct ShortcutRecorderNSView: NSViewRepresentable {
    @Binding var shortcut: KeyboardShortcut?
    @Binding var isRecording: Bool

    func makeNSView(context: Context) -> ShortcutRecorderNSViewImpl {
        let view = ShortcutRecorderNSViewImpl()
        view.onShortcutChange = { newShortcut in
            shortcut = newShortcut
        }
        view.onRecordingStateChange = { recording in
            isRecording = recording
        }
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSViewImpl, context: Context) {
        nsView.shortcut = shortcut
        nsView.needsDisplay = true
    }
}

/// The actual NSView that handles keyboard input
class ShortcutRecorderNSViewImpl: NSView {
    var shortcut: KeyboardShortcut?
    var onShortcutChange: ((KeyboardShortcut?) -> Void)?
    var onRecordingStateChange: ((Bool) -> Void)?
    private var isRecording = false
    private var localMonitor: Any?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.cornerRadius = 6
    }

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        startRecording()
    }

    override func keyDown(with event: NSEvent) {
        if isRecording {
            recordShortcut(from: event)
        } else {
            super.keyDown(with: event)
        }
    }

    private func startRecording() {
        guard !isRecording else { return }

        isRecording = true
        onRecordingStateChange?(true)
        needsDisplay = true

        window?.makeFirstResponder(self)

        // Start monitoring for key events
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.recordShortcut(from: event)
            return nil // Consume the event
        }
    }

    private func stopRecording() {
        guard isRecording else { return }

        isRecording = false
        onRecordingStateChange?(false)
        needsDisplay = true

        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    private func recordShortcut(from event: NSEvent) {
        // Require at least one modifier key
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let hasModifiers = modifiers.contains(.command) ||
                          modifiers.contains(.control) ||
                          modifiers.contains(.option) ||
                          modifiers.contains(.shift)

        guard hasModifiers else {
            // Flash to indicate invalid shortcut
            NSSound.beep()
            return
        }

        // Escape cancels recording
        if event.keyCode == 53 { // Escape
            stopRecording()
            return
        }

        let newShortcut = KeyboardShortcut(
            keyCode: event.keyCode,
            modifierFlags: modifiers.rawValue
        )

        shortcut = newShortcut
        onShortcutChange?(newShortcut)
        stopRecording()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let text: String
        let textColor: NSColor

        if isRecording {
            text = "Press keys..."
            textColor = .secondaryLabelColor
        } else if let shortcut = shortcut {
            text = shortcut.displayString
            textColor = .labelColor
        } else {
            text = "Click to record"
            textColor = .secondaryLabelColor
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let textSize = (text as NSString).size(withAttributes: attributes)
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        (text as NSString).draw(in: textRect, withAttributes: attributes)
    }

    deinit {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
