// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Spreadsheet Content

/// Excel-style spreadsheet with formula bar, column headers, and editable cells.
struct SpreadsheetContent: View {
    
    @State private var cells: [[String]] = [
        ["Product", "Q1", "Q2", "Q3", "Q4", "Total"],
        ["Vision Pro", "12,400", "15,800", "22,100", "31,500", "81,800"],
        ["AirPods", "45,200", "38,600", "42,900", "55,100", "181,800"],
        ["MacBook", "28,300", "32,100", "29,800", "44,200", "134,400"],
        ["iPad", "18,900", "21,400", "24,600", "33,800", "98,700"],
        ["iPhone", "72,100", "68,500", "75,200", "95,400", "311,200"],
        ["Watch", "22,600", "25,300", "28,100", "38,900", "114,900"],
        ["", "", "", "", "", ""],
        ["Total", "199,500", "201,700", "222,700", "298,900", "922,800"],
    ]
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var formulaBarText = ""
    
    private let colWidths: [CGFloat] = [70, 55, 55, 55, 55, 60]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Image(systemName: "tablecells")
                    .font(.system(size: 12))
                    .foregroundStyle(.green)
                Text("Spreadsheet")
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
                
                TextField("", text: $formulaBarText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white)
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
        
        return Button {
            selectedCell = (row, col)
            formulaBarText = cells[row][col]
        } label: {
            Text(cells[row][col])
                .font(.system(size: isHeader ? 9 : 10, weight: isHeader || isTotal ? .bold : .regular, design: col > 0 ? .monospaced : .default))
                .foregroundStyle(isHeader ? .white.opacity(0.6) : isTotal ? .green : .white.opacity(0.8))
                .frame(width: colWidths[col], height: 22, alignment: col == 0 ? .leading : .trailing)
                .padding(.horizontal, 4)
                .background(
                    isSelected ? Color.blue.opacity(0.15) :
                    isHeader ? Color.white.opacity(0.04) :
                    isTotal ? Color.green.opacity(0.04) : .clear
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
}
