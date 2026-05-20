// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Weather Window Content

struct WeatherContent: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("San Francisco")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            HStack(alignment: .top, spacing: 4) {
                Text("65")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(.white)
                Text("°")
                    .font(.system(size: 24, weight: .thin))
                    .foregroundStyle(.white.opacity(0.7))
                    .offset(y: 4)
            }
            
            Image(systemName: "sun.max.fill")
                .font(.system(size: 28))
                .foregroundStyle(.yellow)
                .shadow(color: .yellow.opacity(0.4), radius: 8)
            
            Text("Mostly Sunny")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("H: 67° L: 55°")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.45))
            
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
    }
}
