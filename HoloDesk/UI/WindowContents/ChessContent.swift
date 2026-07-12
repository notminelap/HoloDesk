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
    @State private var moveHistory: [String] = []
    @State private var whiteTime = 600
    @State private var blackTime = 600
    
    // Captured pieces arrays
    @State private var capturedWhite: [ChessPiece] = []
    @State private var capturedBlack: [ChessPiece] = []
    
    @Environment(SpatialAudioManager.self) private var audio
    
    struct ChessPiece: Identifiable {
        let id = UUID()
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
        HStack(spacing: 12) {
            // Board with surrounding coordinates
            VStack(spacing: 4) {
                // Top files coordinate labels
                HStack(spacing: 0) {
                    Spacer().frame(width: 14)
                    ForEach(["a", "b", "c", "d", "e", "f", "g", "h"], id: \.self) { letter in
                        Text(letter)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(width: 30, alignment: .center)
                    }
                    Spacer().frame(width: 14)
                }
                
                HStack(spacing: 4) {
                    // Left ranks coordinate labels
                    VStack(spacing: 0) {
                        ForEach(["8", "7", "6", "5", "4", "3", "2", "1"], id: \.self) { num in
                            Text(num)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white.opacity(0.3))
                                .frame(height: 30)
                        }
                    }
                    .frame(width: 10)
                    
                    // Main chessboard grid
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
                            .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
                    )
                    
                    // Right ranks coordinate labels
                    VStack(spacing: 0) {
                        ForEach(["8", "7", "6", "5", "4", "3", "2", "1"], id: \.self) { num in
                            Text(num)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white.opacity(0.3))
                                .frame(height: 30)
                        }
                    }
                    .frame(width: 10)
                }
                
                // Bottom files coordinate labels
                HStack(spacing: 0) {
                    Spacer().frame(width: 14)
                    ForEach(["a", "b", "c", "d", "e", "f", "g", "h"], id: \.self) { letter in
                        Text(letter)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(width: 30, alignment: .center)
                    }
                    Spacer().frame(width: 14)
                }
            }
            
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
                
                // Captured Pieces Tray (shows captured white & black pieces wrapping dynamically)
                VStack(alignment: .leading, spacing: 4) {
                    if !capturedBlack.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 12, maximum: 16), spacing: 2)], alignment: .leading, spacing: 2) {
                            ForEach(capturedBlack) { piece in
                                Text(piece.symbol)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
                    }
                    
                    if !capturedWhite.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 12, maximum: 16), spacing: 2)], alignment: .leading, spacing: 2) {
                            ForEach(capturedWhite) { piece in
                                Text(piece.symbol)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 6))
                    }
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
                .frame(maxHeight: 70)
                
                // Controls
                HStack(spacing: 8) {
                    Button {
                        board = ChessPiece.startingBoard
                        isWhiteTurn = true
                        moveHistory = []
                        capturedWhite = []
                        capturedBlack = []
                        whiteTime = 600
                        blackTime = 600
                        audio.playSFX(.success)
                        HapticManager.shared.mediumTap()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(4)
                            .background(.white.opacity(0.05), in: Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // Flag resign
                        audio.playSFX(.windowClose)
                        HapticManager.shared.mediumTap()
                    } label: {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red.opacity(0.4))
                            .padding(4)
                            .background(.white.opacity(0.05), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 80)
        }
        .padding(10)
        // Autoconnected 1Hz clock timer publisher
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if whiteTime > 0 && blackTime > 0 {
                if isWhiteTurn {
                    whiteTime -= 1
                } else {
                    blackTime -= 1
                }
            }
        }
    }
    
    private func squareView(row: Int, col: Int) -> some View {
        let isLight = (row + col) % 2 == 0
        let isSelected = selectedSquare?.row == row && selectedSquare?.col == col
        let isTargetHighlight: Bool = {
            if let sel = selectedSquare, let piece = board[sel.row][sel.col] {
                return isValidMove(from: (sel.row, sel.col), to: (row, col), piece: piece)
            }
            return false
        }()
        
        return Button {
            handleTap(row: row, col: col)
        } label: {
            ZStack {
                Rectangle()
                    .fill(
                        isSelected ? Color.yellow.opacity(0.3) :
                        isLight ? Color(white: 0.75).opacity(0.18) : Color(white: 0.25).opacity(0.18)
                    )
                
                // Glowing selected cyan stroke outline
                if isSelected {
                    RoundedRectangle(cornerRadius: 1)
                        .strokeBorder(Color.holoPrimary, lineWidth: 1.5)
                        .shadow(color: Color.holoPrimary.opacity(0.5), radius: 3)
                }
                
                // Soft move trace visual suggestions
                if isTargetHighlight {
                    if board[row][col] != nil {
                        // Opponent capture indicator
                        Circle()
                            .strokeBorder(Color.red.opacity(0.4), lineWidth: 1)
                            .frame(width: 24, height: 24)
                    } else {
                        // Standard movement indicator
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 8, height: 8)
                    }
                }
                
                if let piece = board[row][col] {
                    Text(piece.symbol)
                        .font(.system(size: 22))
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
            if sel.row == row && sel.col == col {
                // Tapped same square, deselect
                selectedSquare = nil
                audio.playSFX(.softTick)
            } else if let movingPiece = board[sel.row][sel.col] {
                // If user clicks another piece of their own color, switch selection
                if let tappedPiece = board[row][col], tappedPiece.isWhite == movingPiece.isWhite {
                    selectedSquare = (row, col)
                    audio.playSFX(.softTick)
                    return
                }
                
                // Validate if move conforms to chess rules
                guard isValidMove(from: (sel.row, sel.col), to: (row, col), piece: movingPiece) else {
                    audio.playSFX(.error)
                    selectedSquare = nil
                    return
                }
                
                let targetPiece = board[row][col]
                
                // Record captured piece
                if let captured = targetPiece {
                    if captured.isWhite {
                        capturedWhite.append(captured)
                    } else {
                        capturedBlack.append(captured)
                    }
                }
                
                // Perform move
                board[row][col] = movingPiece
                board[sel.row][sel.col] = nil
                
                // Generate Algebraic Notation string
                let moveString = makeAlgebraicMove(
                    from: (sel.row, sel.col),
                    to: (row, col),
                    piece: movingPiece,
                    isCapture: targetPiece != nil
                )
                
                // Log the move in history array
                if isWhiteTurn {
                    let turnNumber = moveHistory.count + 1
                    moveHistory.append("\(turnNumber). \(moveString)")
                } else {
                    if !moveHistory.isEmpty {
                        let idx = moveHistory.count - 1
                        moveHistory[idx] = "\(moveHistory[idx]) \(moveString)"
                    } else {
                        moveHistory.append("1. ... \(moveString)")
                    }
                }
                
                isWhiteTurn.toggle()
                if targetPiece != nil {
                    audio.playSFX(.bubblePop)
                } else {
                    audio.playSFX(.tap)
                }
                HapticManager.shared.lightTap()
                selectedSquare = nil
            } else {
                selectedSquare = nil
            }
        } else if let piece = board[row][col], piece.isWhite == isWhiteTurn {
            // Can only select pieces of the current player's turn
            selectedSquare = (row, col)
            audio.playSFX(.softTick)
        }
    }
    
    private func makeAlgebraicMove(from: (row: Int, col: Int), to: (row: Int, col: Int), piece: ChessPiece, isCapture: Bool) -> String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        let ranks = ["8", "7", "6", "5", "4", "3", "2", "1"]
        
        let pChar: String
        switch piece.type {
        case .pawn: pChar = ""
        case .knight: pChar = "N"
        case .bishop: pChar = "B"
        case .rook: pChar = "R"
        case .queen: pChar = "Q"
        case .king: pChar = "K"
        }
        
        let startFile = files[from.col]
        let endFile = files[to.col]
        let endRank = ranks[to.row]
        
        if isCapture {
            if piece.type == .pawn {
                return "\(startFile)x\(endFile)\(endRank)"
            } else {
                return "\(pChar)x\(endFile)\(endRank)"
            }
        } else {
            return "\(pChar)\(endFile)\(endRank)"
        }
    }
    
    // MARK: - Chess Move Validation Engine
    
    private func isValidMove(from: (row: Int, col: Int), to: (row: Int, col: Int), piece: ChessPiece) -> Bool {
        // 1. Cannot move to the exact same square
        if from.row == to.row && from.col == to.col { return false }
        
        // 2. Cannot capture own color
        if let target = board[to.row][to.col], target.isWhite == piece.isWhite {
            return false
        }
        
        let dRow = to.row - from.row
        let dCol = to.col - from.col
        let absDRow = abs(dRow)
        let absDCol = abs(dCol)
        
        switch piece.type {
        case .pawn:
            let direction = piece.isWhite ? -1 : 1
            let startRow = piece.isWhite ? 6 : 1
            
            // Standard single step forward
            if dCol == 0 && dRow == direction && board[to.row][to.col] == nil {
                return true
            }
            // Double step forward from starting rank
            if dCol == 0 && from.row == startRow && dRow == 2 * direction {
                let intermediateRow = from.row + direction
                if board[to.row][to.col] == nil && board[intermediateRow][from.col] == nil {
                    return true
                }
            }
            // Diagonal capture
            if absDCol == 1 && dRow == direction {
                if let target = board[to.row][to.col], target.isWhite != piece.isWhite {
                    return true
                }
            }
            return false
            
        case .knight:
            return (absDRow == 2 && absDCol == 1) || (absDRow == 1 && absDCol == 2)
            
        case .bishop:
            if absDRow != absDCol { return false }
            return isPathClear(from: from, to: to)
            
        case .rook:
            if dRow != 0 && dCol != 0 { return false }
            return isPathClear(from: from, to: to)
            
        case .queen:
            if absDRow != absDCol && dRow != 0 && dCol != 0 { return false }
            return isPathClear(from: from, to: to)
            
        case .king:
            return absDRow <= 1 && absDCol <= 1
        }
    }
    
    private func isPathClear(from: (row: Int, col: Int), to: (row: Int, col: Int)) -> Bool {
        let stepRow = (to.row - from.row) == 0 ? 0 : ((to.row - from.row) > 0 ? 1 : -1)
        let stepCol = (to.col - from.col) == 0 ? 0 : ((to.col - from.col) > 0 ? 1 : -1)
        
        var currRow = from.row + stepRow
        var currCol = from.col + stepCol
        
        while currRow != to.row || currCol != to.col {
            if board[currRow][currCol] != nil {
                return false
            }
            currRow += stepRow
            currCol += stepCol
        }
        return true
    }
}
