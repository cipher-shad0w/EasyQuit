//
//  AppRow.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import SwiftUI
import AppKit

struct AppRow: View {
    let app: RunningApp
    let isSelected: Bool
    let onQuit: (Bool) -> Void
    let onRestart: () -> Void
    let onShowInFinder: () -> Void
    let onIgnore: () -> Void
    @State private var isHovered = false
    @State private var isClosing = false

    var body: some View {
        VStack(spacing: 0) {
            // App Icon only
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 64, height: 64)
            }
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected || isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : (isHovered ? Color.accentColor.opacity(0.3) : Color.clear), lineWidth: isSelected ? 3 : 2)
        )
        .scaleEffect(isClosing ? 0.6 : 1.0)
        .opacity(isClosing ? 0.0 : 1.0)
        .blur(radius: isClosing ? 8 : 0)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture(count: 2) {
            // Double click = normal quit with animation
            animateClose {
                onQuit(false)
            }
        }
        .contextMenu {
            Button("Quit") {
                animateClose {
                    onQuit(false)
                }
            }
            Button("Force Quit") {
                animateClose {
                    onQuit(true)
                }
            }

            Divider()

            Button("Restart App") {
                animateClose {
                    onRestart()
                }
            }

            Divider()

            Button("Show in Finder") {
                onShowInFinder()
            }

            Divider()

            Button("Hide from List") {
                animateClose {
                    onIgnore()
                }
            }
        }
    }

    private func animateClose(completion: @escaping () -> Void) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
            isClosing = true
        }

        // Execute the actual close action after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            completion()
        }
    }
}
