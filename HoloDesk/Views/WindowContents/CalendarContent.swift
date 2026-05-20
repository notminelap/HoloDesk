// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Calendar Window Content

/// Monthly calendar with event sidebar — matches visionOS calendar aesthetic.
struct CalendarContent: View {
    
    private let currentMonth = "April 2025"
    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    private let today = 8  // Highlighted day
    
    // Calendar grid (April 2025 starting on Tuesday)
    private let dates: [Int?] = [
        nil, nil, 1, 2, 3, 4, 5,
        6, 7, 8, 9, 10, 11, 12,
        13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26,
        27, 28, 29, 30, nil, nil, nil
    ]
    
    private let events: [(time: String, title: String, color: Color)] = [
        ("10:00 - 11:00 AM", "Team Sync", .blue),
        ("1:00 - 2:30 PM", "Project Review", .purple),
        ("3:30 - 4:30 PM", "Client Call", .orange),
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Calendar grid
            calendarGrid
            
            Divider().overlay(Color.white.opacity(0.08))
            
            // Events sidebar
            eventsSidebar
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Month header
            HStack {
                Text("Calendar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                
                // Notification badge
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 20, height: 20)
                    Text("3")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            
            Text(currentMonth)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Day headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(height: 18)
                }
                
                // Date cells
                ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dateCell(date)
                    } else {
                        Text("")
                            .frame(height: 26)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
    }
    
    private func dateCell(_ date: Int) -> some View {
        let isToday = date == today
        
        return Text("\(date)")
            .font(.system(size: 12, weight: isToday ? .bold : .regular))
            .foregroundStyle(isToday ? .white : .white.opacity(0.7))
            .frame(width: 26, height: 26)
            .background(
                Circle()
                    .fill(isToday ? Color.calendarHighlight : .clear)
            )
    }
    
    // MARK: - Events Sidebar
    
    private var eventsSidebar: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(events.enumerated()), id: \.offset) { _, event in
                eventRow(event)
            }
            Spacer()
        }
        .padding(12)
        .frame(width: 180)
        .background(.black.opacity(0.1))
    }
    
    private func eventRow(_ event: (time: String, title: String, color: Color)) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 3, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text(event.time)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}
