// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import os.log

// MARK: - HoloDesk Logger

/// Unified logging facade using os.log — replaces all print() calls.
/// Provides subsystem-scoped logging for debug builds only.
enum HoloDeskLogger {
    
    private static let subsystem = "com.notminelap.holodesk"
    
    static let spatial = Logger(subsystem: subsystem, category: "Spatial")
    static let audio   = Logger(subsystem: subsystem, category: "Audio")
    static let ai      = Logger(subsystem: subsystem, category: "AI")
    static let general = Logger(subsystem: subsystem, category: "General")
}
