// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Stocks & Finance Content

/// Bloomberg-style financial dashboard with charts, watchlist, and market data.
struct StocksContent: View {
    
    @State private var selectedStock: Int = 0
    @State private var timeRange: String = "1D"
    
    private let stocks: [(symbol: String, name: String, price: String, change: String, isUp: Bool, chartData: [CGFloat])] = [
        ("AAPL", "Apple Inc.", "198.45", "+2.34 (1.19%)", true, [0.4, 0.45, 0.42, 0.5, 0.55, 0.52, 0.58, 0.62, 0.6, 0.65, 0.63, 0.68, 0.72, 0.7, 0.75]),
        ("GOOGL", "Alphabet Inc.", "175.82", "+1.23 (0.70%)", true, [0.5, 0.48, 0.52, 0.55, 0.53, 0.58, 0.56, 0.6, 0.58, 0.62, 0.65, 0.63, 0.67, 0.65, 0.68]),
        ("MSFT", "Microsoft Corp.", "425.67", "-3.12 (-0.73%)", false, [0.7, 0.68, 0.65, 0.67, 0.63, 0.65, 0.6, 0.62, 0.58, 0.6, 0.55, 0.57, 0.53, 0.55, 0.52]),
        ("TSLA", "Tesla Inc.", "182.30", "+5.67 (3.21%)", true, [0.3, 0.35, 0.32, 0.4, 0.45, 0.5, 0.48, 0.55, 0.6, 0.58, 0.65, 0.7, 0.68, 0.75, 0.8]),
        ("AMZN", "Amazon.com", "186.49", "+0.89 (0.48%)", true, [0.5, 0.52, 0.51, 0.53, 0.55, 0.54, 0.56, 0.55, 0.57, 0.58, 0.56, 0.59, 0.58, 0.6, 0.61]),
        ("NVDA", "NVIDIA Corp.", "924.15", "+12.45 (1.36%)", true, [0.2, 0.25, 0.3, 0.35, 0.4, 0.38, 0.45, 0.5, 0.55, 0.6, 0.58, 0.65, 0.7, 0.75, 0.8]),
    ]
    
    private let indices: [(name: String, value: String, change: String, isUp: Bool)] = [
        ("S&P 500", "5,267.84", "+0.42%", true),
        ("NASDAQ", "16,742.39", "+0.68%", true),
        ("DOW", "39,431.51", "-0.12%", false),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Market indices ticker
            HStack(spacing: 12) {
                ForEach(Array(indices.enumerated()), id: \.offset) { _, index in
                    HStack(spacing: 4) {
                        Text(index.name)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                        Text(index.change)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(index.isUp ? .green : .red)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.black.opacity(0.2))
            
            // Chart
            VStack(spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stocks[selectedStock].symbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        Text(stocks[selectedStock].name)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(stocks[selectedStock].price)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                        Text(stocks[selectedStock].change)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(stocks[selectedStock].isUp ? .green : .red)
                    }
                }
                
                // Mini chart
                chartView(data: stocks[selectedStock].chartData, isUp: stocks[selectedStock].isUp)
                    .frame(height: 80)
                
                // Time range picker
                HStack(spacing: 0) {
                    ForEach(["1D", "1W", "1M", "3M", "1Y", "ALL"], id: \.self) { range in
                        Button {
                            timeRange = range
                        } label: {
                            Text(range)
                                .font(.system(size: 9, weight: timeRange == range ? .bold : .regular))
                                .foregroundStyle(timeRange == range ? .white : .white.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(
                                    timeRange == range ? Color.white.opacity(0.08) : .clear,
                                    in: RoundedRectangle(cornerRadius: 4)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Watchlist
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(stocks.enumerated()), id: \.offset) { index, stock in
                        Button { selectedStock = index } label: {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stock.symbol)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(selectedStock == index ? .white : .white.opacity(0.8))
                                    Text(stock.name)
                                        .font(.system(size: 8))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                // Sparkline
                                miniChart(data: stock.chartData, isUp: stock.isUp)
                                    .frame(width: 40, height: 18)
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("$\(stock.price)")
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.white)
                                    Text(stock.isUp ? "↑" : "↓")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(stock.isUp ? .green : .red)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedStock == index ? Color.white.opacity(0.04) : .clear)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func chartView(data: [CGFloat], isUp: Bool) -> some View {
        Canvas { context, size in
            guard data.count > 1 else { return }
            let color = isUp ? Color.green : Color.red
            
            var path = Path()
            for (i, point) in data.enumerated() {
                let x = size.width * CGFloat(i) / CGFloat(data.count - 1)
                let y = size.height * (1 - point)
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Fill gradient
            var fill = path
            fill.addLine(to: CGPoint(x: size.width, y: size.height))
            fill.addLine(to: CGPoint(x: 0, y: size.height))
            fill.closeSubpath()
            context.fill(fill, with: .linearGradient(
                Gradient(colors: [color.opacity(0.2), color.opacity(0)]),
                startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: size.height)
            ))
        }
    }
    
    private func miniChart(data: [CGFloat], isUp: Bool) -> some View {
        Canvas { context, size in
            guard data.count > 1 else { return }
            var path = Path()
            for (i, point) in data.enumerated() {
                let x = size.width * CGFloat(i) / CGFloat(data.count - 1)
                let y = size.height * (1 - point)
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            context.stroke(path, with: .color(isUp ? .green : .red), style: StrokeStyle(lineWidth: 1, lineCap: .round))
        }
    }
}
