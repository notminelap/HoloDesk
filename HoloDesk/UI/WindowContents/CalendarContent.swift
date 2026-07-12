// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Calendar Window Content (Interactive)

/// Monthly calendar with event sidebar — real date computation, event colors, today highlight.
struct CalendarContent: View {
    
    @State private var selectedDate: Int?
    @State private var displayMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let dayHeaders = ["S", "M", "T", "W", "T", "F", "S"]
    
    private let events: [Int: [(time: String, title: String, color: Color)]] = [
        8:  [("10:00 AM", "Team Sync", .blue), ("2:00 PM", "Code Review", .purple)],
        12: [("9:00 AM", "Sprint Planning", .orange)],
        15: [("1:00 PM", "Client Call", .green), ("3:30 PM", "Design Review", .pink)],
        20: [("11:00 AM", "1:1 with Manager", .cyan)],
        22: [("4:00 PM", "Release Prep", .red)],
        25: [("10:00 AM", "All Hands", .blue), ("2:00 PM", "Tech Talk", .purple), ("4:30 PM", "Happy Hour", .orange)],
    ]
    
    private var today: Int { calendar.component(.day, from: Date()) }
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayMonth)
    }
    
    private var datesGrid: [Int?] {
        let components = calendar.dateComponents([.year, .month], from: displayMonth)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        var grid: [Int?] = Array(repeating: nil, count: firstWeekday)
        for day in range { grid.append(day) }
        while grid.count % 7 != 0 { grid.append(nil) }
        return grid
    }
    
    var body: some View {
        HStack(spacing: 0) {
            calendarGrid
            Divider().overlay(Color.white.opacity(0.06))
            eventsSidebar
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 6) {
            // Month header with nav
            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(monthString)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            
            // Day headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 3) {
                ForEach(dayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(height: 16)
                }
                
                ForEach(Array(datesGrid.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dateCell(date)
                    } else {
                        Text("")
                            .frame(height: 28)
                    }
                }
            }
            
            Spacer()
            
            // Today button
            Button {
                displayMonth = Date()
                selectedDate = today
            } label: {
                Text("Today")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.holoPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
    }
    
    private func dateCell(_ date: Int) -> some View {
        let isToday = date == today
        let isSelected = date == selectedDate
        let hasEvents = events[date] != nil
        
        return Button {
            withAnimation(.spring(response: 0.2)) { selectedDate = date }
        } label: {
            VStack(spacing: 1) {
                Text("\(date)")
                    .font(.system(size: 11, weight: isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? Color.white : isSelected ? Color.holoPrimary : Color.white.opacity(0.7))
                
                // Event dot
                if hasEvents {
                    Circle()
                        .fill(events[date]?.first?.color ?? .blue)
                        .frame(width: 3, height: 3)
                } else {
                    Color.clear.frame(width: 3, height: 3)
                }
            }
            .frame(width: 28, height: 28)
            .background(
                ZStack {
                    if isToday {
                        Circle().fill(Color.holoPrimary.opacity(0.3))
                    }
                    if isSelected && !isToday {
                        Circle().strokeBorder(Color.holoPrimary.opacity(0.4), lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Events Sidebar
    
    private var eventsSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(selectedDate != nil ? "Events — \(selectedDate!)" : "Events")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                
                // Event count badge
                if let sel = selectedDate, let evts = events[sel] {
                    Text("\(evts.count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.holoPrimary.opacity(0.4), in: Circle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Divider().overlay(Color.white.opacity(0.05))
            
            // Events list
            ScrollView {
                if let sel = selectedDate, let dayEvents = events[sel] {
                    VStack(spacing: 6) {
                        ForEach(Array(dayEvents.enumerated()), id: \.offset) { _, event in
                            eventRow(event)
                        }
                    }
                    .padding(10)
                } else {
                    VStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.15))
                        Text("Select a date")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.2))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(width: 170)
        .background(.black.opacity(0.06))
    }
    
    private func eventRow(_ event: (time: String, title: String, color: Color)) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 3, height: 36)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text(event.time)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
        }
        .padding(8)
        .innerGlass(cornerRadius: 8)
    }
    
    private func changeMonth(_ delta: Int) {
        if let newDate = calendar.date(byAdding: .month, value: delta, to: displayMonth) {
            withAnimation(.spring(response: 0.3)) {
                displayMonth = newDate
                selectedDate = nil
            }
        }
    }
}
