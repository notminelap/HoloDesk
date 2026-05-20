// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Todo Window Content

struct TodoContent: View {
    @State private var items: [(text: String, done: Bool)] = [
        ("Finish monthly report", false),
        ("Review Q4 budget", false),
        ("Email design team", true),
        ("Prepare client deck", false),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("To-Do")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(items.filter { !$0.done }.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .innerGlass(cornerRadius: 8)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button {
                    items[index].done.toggle()
                } label: {
                    HStack(spacing: 10) {
                        Circle()
                            .strokeBorder(item.done ? Color.holoSuccess : .white.opacity(0.3), lineWidth: 1.5)
                            .background(Circle().fill(item.done ? Color.holoSuccess.opacity(0.2) : .clear))
                            .frame(width: 20, height: 20)
                            .overlay(
                                item.done ? Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.holoSuccess) : nil
                            )
                        
                        Text(item.text)
                            .font(.system(size: 13))
                            .foregroundStyle(item.done ? .white.opacity(0.35) : .white.opacity(0.85))
                            .strikethrough(item.done, color: .white.opacity(0.2))
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
            }
            
            Spacer()
        }
    }
}
