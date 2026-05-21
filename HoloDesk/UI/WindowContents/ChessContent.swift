// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Spatial Chess Content

/// Interactive chess board with move history, captured pieces, and timers.
struct ChessContent: View {
    
    @State private var board: [[ChessPiece?]] = ChessPiece.startingBoard
    @State private var selectedSquare: (row: Int, col: Int)?
    @State private var isWhiteTurn = true
    @State private var moveHistory: [String] = ["1. e4 e5", "2. Nf3 Nc6", "3. Bb5"]
    @State private var whiteTime = 600
    @State private var blackTime = 600
    
    @Environment(SpatialAudioManager.self) private var audio
    
    struct ChessPiece {
        var type: PieceType
        var isWhite: Bool
        
        enum PieceType: String {
            case king, queen, rook, bishop, knight, pawn
            
            var symbol: (white: String, black: String) {
                switch self {
                case .king:   return ("♔", "♚")
                case .queen:  return ("♕", "♛")
                case .rook:   return ("♖", "♜")
                case .bishop: return ("♗", "♝")
                case .knight: return ("♘", "♞")
                case .pawn:   return ("♙", "♟")
                }
            }
        }
        
        var symbol: String {
            isWhite ? type.symbol.white : type.symbol.black
        }
        
        static var startingBoard: [[ChessPiece?]] {
            let backRow: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
            return [
                backRow.map { ChessPiece(type: $0, isWhite: false) },
                Array(repeating: ChessPiece(type: .pawn, isWhite: false), count: 8),
                Array(repeating: nil, count: 8),
                Array(repeating: nil, count: 8),
                Array(repeating: nil, count: 8),
                Array(repeating: nil, count: 8),
                Array(repeating: ChessPiece(type: .pawn, isWhite: true), count: 8),
                backRow.map { ChessPiece(type: $0, isWhite: true) },
            ]
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Board
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            squareView(row: row, col: col)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
            )
            
            // Side panel
            VStack(alignment: .leading, spacing: 8) {
                // Turn indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(isWhiteTurn ? .white : .black)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: 0.5))
                    Text(isWhiteTurn ? "White" : "Black")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                // Timers
                VStack(spacing: 4) {
                    timerView(time: blackTime, label: "Black", isActive: !isWhiteTurn)
                    timerView(time: whiteTime, label: "White", isActive: isWhiteTurn)
                }
                
                Divider().overlay(Color.white.opacity(0.06))
                
                // Move history
                Text("Moves")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(moveHistory.enumerated()), id: \.offset) { _, move in
                            Text(move)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .frame(maxHeight: 80)
                
                // Controls
                HStack(spacing: 6) {
                    Button {
                        board = ChessPiece.startingBoard
                        isWhiteTurn = true
                        moveHistory = []
                        audio.playSFX(.success)
                        HapticManager.shared.mediumTap()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    
                    Button { } label: {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 80)
        }
        .padding(10)
    }
    
    private func squareView(row: Int, col: Int) -> some View {
        let isLight = (row + col) % 2 == 0
        let isSelected = selectedSquare?.row == row && selectedSquare?.col == col
        
        return Button {
            handleTap(row: row, col: col)
        } label: {
            ZStack {
                Rectangle()
                    .fill(
                        isSelected ? Color.yellow.opacity(0.4) :
                        isLight ? Color(white: 0.7).opacity(0.25) : Color(white: 0.3).opacity(0.25)
                    )
                
                if let piece = board[row][col] {
                    Text(piece.symbol)
                        .font(.system(size: 20))
                        .shadow(color: .black.opacity(0.3), radius: 1)
                }
            }
            .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
    }
    
    private func timerView(time: Int, label: String, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.white.opacity(0.3))
            Spacer()
            Text(String(format: "%d:%02d", time / 60, time % 60))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(isActive ? .white : .white.opacity(0.3))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(isActive ? Color.white.opacity(0.06) : .clear, in: RoundedRectangle(cornerRadius: 4))
    }
    
    private func handleTap(row: Int, col: Int) {
        if let sel = selectedSquare {
            // Move piece
            if board[sel.row][sel.col] != nil {
                board[row][col] = board[sel.row][sel.col]
                board[sel.row][sel.col] = nil
                isWhiteTurn.toggle()
                audio.playSFX(.tap)
                HapticManager.shared.lightTap()
            } else {
                audio.playSFX(.softTick)
            }
            selectedSquare = nil
        } else if board[row][col] != nil {
            selectedSquare = (row, col)
            audio.playSFX(.softTick)
        }
    }
}
