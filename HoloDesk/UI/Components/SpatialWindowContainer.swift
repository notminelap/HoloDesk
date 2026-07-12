// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

/// Container that manages the lifecycle of individual visionOS windows.
/// Ensures that when a window model is removed from the store, the actual
/// floating OS window is programmatically dismissed using the SwiftUI environment.
struct SpatialWindowContainer: View {
    let windowId: UUID?
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        if let id = windowId, let window = store.window(for: id) {
            SpatialWindowView(window: window)
                .onDisappear {
                    // If the view disappeared because it was removed from the active list
                    if store.window(for: id) == nil {
                        dismissWindow(id: "spatial-window", value: id)
                    }
                }
        } else if let id = windowId {
            // Handle edge case where the view was initialized with an ID that is no longer in the store
            Color.clear
                .onAppear {
                    dismissWindow(id: "spatial-window", value: id)
                }
        }
    }
}
