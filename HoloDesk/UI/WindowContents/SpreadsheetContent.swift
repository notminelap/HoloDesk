// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Spreadsheet Content

/// Excel-style spreadsheet with formula bar, column headers, live-calculation formula engine, and CSV export.
struct SpreadsheetContent: View {
    
    @State private var cells: [[String]] = [
        ["Product", "Q1", "Q2", "Q3", "Q4", "Total"],
        ["Vision Pro", "12400", "15800", "22100", "31500", "=SUM(B2:E2)"],
        ["AirPods", "45200", "38600", "42900", "55100", "=SUM(B3:E3)"],
        ["MacBook", "28300", "32100", "29800", "44200", "=SUM(B4:E4)"],
        ["iPad", "18900", "21400", "24600", "33800", "=SUM(B5:E5)"],
        ["iPhone", "72100", "68500", "75200", "95400", "=SUM(B6:E6)"],
        ["Watch", "22600", "25300", "28100", "38900", "=SUM(B7:E7)"],
        ["", "", "", "", "", ""],
        ["Total", "=SUM(B2:B7)", "=SUM(C2:C7)", "=SUM(D2:D7)", "=SUM(E2:E7)", "=SUM(F2:F7)"],
    ]
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var formulaBarText = ""
    
    @Environment(SpatialAudioManager.self) private var audio
    
    private let colWidths: [CGFloat] = [70, 55, 55, 55, 55, 60]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Image(systemName: "tablecells")
                    .font(.system(size: 12))
                    .foregroundStyle(.green)
                Text("Spreadsheet Pro")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                
                HStack(spacing: 4) {
                    toolbarButton("bold")
                    toolbarButton("italic")
                    toolbarButton("underline")
                    Divider().frame(height: 12).overlay(Color.white.opacity(0.1))
                    toolbarButton("paintpalette")
                    toolbarButton("chart.bar")
                    
                    Divider().frame(height: 12).overlay(Color.white.opacity(0.1))
                    
                    // Export CSV button
                    Button(action: exportToCSV) {
                        HStack(spacing: 3) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 9))
                            Text("Export")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.1), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.15))
            
            // Formula bar
            HStack(spacing: 6) {
                Text(cellRef)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)
                    .frame(width: 30)
                
                Text("fx")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
                
                TextField("Select a cell to edit", text: $formulaBarText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white)
                    .disabled(selectedCell == nil)
                    .onChange(of: formulaBarText) { _, newValue in
                        if let sel = selectedCell {
                            cells[sel.row][sel.col] = newValue
                        }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.white.opacity(0.03))
            
            // Grid
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 0) {
                    // Column headers
                    HStack(spacing: 0) {
                        // Row number header
                        Text("")
                            .frame(width: 24, height: 20)
                            .background(.white.opacity(0.04))
                        
                        ForEach(0..<6, id: \.self) { col in
                            Text(String(UnicodeScalar(65 + col)!))
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: colWidths[col], height: 20)
                                .background(.white.opacity(0.04))
                                .overlay(alignment: .trailing) {
                                    Rectangle().fill(.white.opacity(0.06)).frame(width: 0.5)
                                }
                        }
                    }
                    
                    // Data rows
                    ForEach(0..<cells.count, id: \.self) { row in
                        HStack(spacing: 0) {
                            // Row number
                            Text("\(row + 1)")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.3))
                                .frame(width: 24, height: 22)
                                .background(.white.opacity(0.02))
                            
                            ForEach(0..<min(cells[row].count, 6), id: \.self) { col in
                                cellView(row: row, col: col)
                            }
                        }
                        
                        Divider().overlay(Color.white.opacity(0.03))
                    }
                }
            }
        }
    }
    
    private func cellView(row: Int, col: Int) -> some View {
        let isSelected = selectedCell?.row == row && selectedCell?.col == col
        let isHeader = row == 0
        let isTotal = row == cells.count - 1
        
        let displayVal = displayValue(for: row, col: col)
        
        return Button {
            selectedCell = (row, col)
            formulaBarText = cells[row][col]
            audio.playSFX(.softTick)
        } label: {
            Text(displayVal)
                .font(.system(size: isHeader ? 9 : 10, weight: isHeader || isTotal ? .bold : .regular, design: col > 0 ? .monospaced : .default))
                .foregroundStyle(isHeader ? .white.opacity(0.6) : isTotal ? .green : .white.opacity(0.8))
                .frame(width: colWidths[col], height: 22, alignment: col == 0 ? .leading : .trailing)
                .padding(.horizontal, 4)
                .background(
                    ZStack(alignment: .leading) {
                        if isSelected {
                            Color.blue.opacity(0.15)
                        } else if isHeader {
                            Color.white.opacity(0.04)
                        } else if isTotal {
                            Color.green.opacity(0.04)
                        } else {
                            Color.clear
                        }
                        
                        // Data visualizer bars for numeric content
                        if !isHeader && !isTotal && col > 0 {
                            GeometryReader { geo in
                                if let numericVal = Double(displayVal.replacingOccurrences(of: ",", with: "")) {
                                    let maxVal = 100000.0 // Scaled maximum for display
                                    let fraction = min(1.0, numericVal / maxVal)
                                    Rectangle()
                                        .fill(Color.green.opacity(0.12))
                                        .frame(width: geo.size.width * CGFloat(fraction))
                                }
                            }
                        }
                    }
                )
                .overlay(
                    Rectangle()
                        .strokeBorder(isSelected ? .blue : .clear, lineWidth: 1.5)
                )
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.white.opacity(0.04)).frame(width: 0.5)
                }
        }
        .buttonStyle(.plain)
    }
    
    private func toolbarButton(_ icon: String) -> some View {
        Button { } label: {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.plain)
    }
    
    private var cellRef: String {
        guard let sel = selectedCell else { return "" }
        let col = String(UnicodeScalar(65 + sel.col)!)
        return "\(col)\(sel.row + 1)"
    }
    
    // MARK: - Live Calculation Formula Engine
    
    private func displayValue(for row: Int, col: Int) -> String {
        let content = cells[row][col]
        if content.hasPrefix("=") {
            return evaluateFormula(content)
        }
        
        // Format static numbers with thousands separators
        if row > 0 && col > 0, let val = Double(content) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: val)) ?? content
        }
        
        return content
    }
    
    private func evaluateFormula(_ formula: String) -> String {
        let clean = formula.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // SUM Formula Engine (e.g. =SUM(B2:E2) or =SUM(B2:B7))
        if clean.hasPrefix("=SUM(") && clean.hasSuffix(")") {
            let rangeString = clean
                .replacingOccurrences(of: "=SUM(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            let parts = rangeString.split(separator: ":")
            if parts.count == 2 {
                let startRef = String(parts[0])
                let endRef = String(parts[1])
                
                if let start = parseCellReference(startRef),
                   let end = parseCellReference(endRef) {
                    var sum: Double = 0
                    for r in min(start.row, end.row)...max(start.row, end.row) {
                        for c in min(start.col, end.col)...max(start.col, end.col) {
                            if r < cells.count && c < cells[r].count {
                                // Recursively evaluate cell displaying if it's a formula
                                let cellVal = displayValue(for: r, col: c).replacingOccurrences(of: ",", with: "")
                                if let val = Double(cellVal) {
                                    sum += val
                                }
                            }
                        }
                    }
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 2
                    return formatter.string(from: NSNumber(value: sum)) ?? "\(sum)"
                }
            }
        }
        
        // Simple Addition Engine (e.g. =B2+C2)
        if clean.hasPrefix("=") && clean.contains("+") {
            let parts = clean.replacingOccurrences(of: "=", with: "").split(separator: "+")
            if parts.count == 2 {
                let leftRef = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let rightRef = String(parts[1]).trimmingCharacters(in: .whitespaces)
                
                if let left = parseCellReference(leftRef),
                   let right = parseCellReference(rightRef) {
                    var sum: Double = 0
                    if left.row < cells.count && left.col < cells[left.row].count {
                        let leftVal = displayValue(for: left.row, col: left.col).replacingOccurrences(of: ",", with: "")
                        sum += Double(leftVal) ?? 0
                    }
                    if right.row < cells.count && right.col < cells[right.row].count {
                        let rightVal = displayValue(for: right.row, col: right.col).replacingOccurrences(of: ",", with: "")
                        sum += Double(rightVal) ?? 0
                    }
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 2
                    return formatter.string(from: NSNumber(value: sum)) ?? "\(sum)"
                }
            }
        }
        
        return "ERR!"
    }
    
    private func parseCellReference(_ ref: String) -> (row: Int, col: Int)? {
        let cleanRef = ref.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanRef.isEmpty else { return nil }
        
        guard let firstChar = cleanRef.first, firstChar.isLetter,
              let asciiVal = firstChar.asciiValue else { return nil }
        
        let col = Int(asciiVal - 65) // 65 is ascii value of 'A'
        let rowString = cleanRef.dropFirst()
        guard let row = Int(rowString) else { return nil }
        
        return (row - 1, col)
    }
    
    // MARK: - CSV Export Action
    
    private func exportToCSV() {
        var csvString = ""
        for row in 0..<cells.count {
            let rowItems = (0..<cells[row].count).map { col in
                let val = displayValue(for: row, col: col)
                if val.contains(",") || val.contains("\"") {
                    let escapedVal = val.replacingOccurrences(of: "\"", with: "\"\"")
                    return "\"\(escapedVal)\""
                }
                return val
            }
            csvString += rowItems.joined(separator: ",") + "\n"
        }
        
        // Write to Documents directory
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent("HoloDesk_Export.csv")
            do {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                audio.playSFX(.success)
                HapticManager.shared.success()
            } catch {
                audio.playSFX(.error)
            }
        }
    }
}
