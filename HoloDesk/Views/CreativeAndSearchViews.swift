// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Creative Studio Panel

struct CreativeStudioPanel: View {
    @Environment(CreativeToolkit.self) private var creative
    @Binding var isPresented: Bool
    @State private var activeTab = 0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🎨 Creative Studio").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            HStack(spacing: 0) {
                ForEach(["Layers", "Assets", "Tracks", "Board"], id: \.self) { tab in
                    let idx = ["Layers", "Assets", "Tracks", "Board"].firstIndex(of: tab)!
                    Button { activeTab = idx } label: {
                        Text(tab).font(.system(size: 10, weight: activeTab == idx ? .bold : .regular))
                            .foregroundStyle(activeTab == idx ? .white : .white.opacity(0.3))
                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                            .background(activeTab == idx ? Color.white.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 6))
                    }.buttonStyle(.plain)
                }
            }.innerGlass(cornerRadius: 8)
            
            ScrollView {
                switch activeTab {
                case 0: layersView
                case 1: assetsView
                case 2: tracksView
                case 3: moodBoardView
                default: EmptyView()
                }
            }.frame(maxHeight: 280)
        }.padding(20).frame(width: 400).glassBackground(cornerRadius: 24)
    }
    
    // MARK: - Layers
    private var layersView: some View {
        VStack(spacing: 3) {
            ForEach(creative.layers) { layer in
                HStack(spacing: 8) {
                    Button { creative.toggleLayerVisibility(layer.id) } label: {
                        Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                            .font(.system(size: 10)).foregroundStyle(layer.isVisible ? .white : .white.opacity(0.2))
                    }.buttonStyle(.plain)
                    
                    Text(layer.name).font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(layer.isVisible ? 0.8 : 0.3))
                    Spacer()
                    
                    Text("\(Int(layer.opacity * 100))%").font(.system(size: 8, design: .monospaced)).foregroundStyle(.white.opacity(0.3))
                    
                    if layer.isLocked {
                        Image(systemName: "lock.fill").font(.system(size: 8)).foregroundStyle(.orange.opacity(0.5))
                    }
                }.padding(6).innerGlass(cornerRadius: 6)
            }
        }
    }
    
    // MARK: - Assets
    private var assetsView: some View {
        VStack(spacing: 3) {
            ForEach(creative.recentAssets) { asset in
                HStack(spacing: 8) {
                    Image(systemName: asset.type.rawValue).font(.system(size: 12))
                        .foregroundStyle(.purple).frame(width: 24)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(asset.name).font(.system(size: 10, weight: .medium)).foregroundStyle(.white)
                        Text(asset.size).font(.system(size: 7)).foregroundStyle(.white.opacity(0.3))
                    }
                    Spacer()
                    Button { } label: {
                        Text("Import").font(.system(size: 8, weight: .bold)).foregroundStyle(.purple)
                            .padding(.horizontal, 6).padding(.vertical, 3).innerGlass(cornerRadius: 4)
                    }.buttonStyle(.plain)
                }.padding(6).innerGlass(cornerRadius: 6)
            }
        }
    }
    
    // MARK: - Music Tracks
    private var tracksView: some View {
        VStack(spacing: 3) {
            ForEach(creative.tracks) { track in
                HStack(spacing: 8) {
                    Text(track.instrument).font(.system(size: 16))
                    Text(track.name).font(.system(size: 11, weight: .medium)).foregroundStyle(.white)
                    Spacer()
                    
                    // Volume bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.06)).frame(height: 4)
                            Capsule().fill(track.isMuted ? .red.opacity(0.3) : .green)
                                .frame(width: geo.size.width * track.volume, height: 4)
                        }
                    }.frame(width: 50, height: 4)
                    
                    HStack(spacing: 4) {
                        Image(systemName: track.isMuted ? "speaker.slash" : "speaker.wave.2")
                            .font(.system(size: 8)).foregroundStyle(track.isMuted ? .red : .white.opacity(0.4))
                        if track.isSolo {
                            Text("S").font(.system(size: 7, weight: .bold)).foregroundStyle(.yellow)
                                .padding(2).background(.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 2))
                        }
                    }
                }.padding(6).innerGlass(cornerRadius: 6)
            }
        }
    }
    
    // MARK: - Mood Board
    private var moodBoardView: some View {
        VStack(spacing: 6) {
            Text("Drag items to arrange your mood board").font(.system(size: 9)).foregroundStyle(.white.opacity(0.3))
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.02)).frame(height: 200)
                ForEach(creative.moodBoardItems) { item in
                    switch item.type {
                    case .colorSwatch:
                        RoundedRectangle(cornerRadius: 6).fill(item.color).frame(width: item.size.width, height: item.size.height)
                            .rotationEffect(.degrees(item.rotation)).position(item.position)
                    case .textNote, .inspiration:
                        Text(item.content).font(.system(size: 9, weight: .medium)).foregroundStyle(.white)
                            .padding(6).background(item.color, in: RoundedRectangle(cornerRadius: 4))
                            .rotationEffect(.degrees(item.rotation)).position(item.position)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}

// MARK: - Spotlight Search View

struct SpotlightSearchView: View {
    @State private var search = SpotlightSpatialSearch()
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(.white.opacity(0.4))
                TextField("Search HoloDesk...", text: Binding(
                    get: { search.query },
                    set: { search.query = $0; search.search($0) }
                )).textFieldStyle(.plain).font(.system(size: 14)).foregroundStyle(.white)
                
                if !search.query.isEmpty {
                    Button { search.query = ""; search.results = [] } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundStyle(.white.opacity(0.3))
                    }.buttonStyle(.plain)
                }
            }.padding(14).innerGlass(cornerRadius: 14)
            
            // Results
            if !search.results.isEmpty {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(search.results) { result in
                            Button {
                                isPresented = false
                                HapticManager.shared.lightTap()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: result.icon).font(.system(size: 14)).foregroundStyle(result.color).frame(width: 28)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(result.title).font(.system(size: 12, weight: .medium)).foregroundStyle(.white)
                                        Text(result.subtitle).font(.system(size: 9)).foregroundStyle(.white.opacity(0.3))
                                    }
                                    Spacer()
                                    Text(result.type == .window ? "⌘N" : "").font(.system(size: 8, design: .monospaced)).foregroundStyle(.white.opacity(0.15))
                                }.padding(.horizontal, 10).padding(.vertical, 6)
                            }.buttonStyle(.plain)
                        }
                    }
                }.frame(maxHeight: 280)
            }
        }.padding(16).frame(width: 450).glassBackground(cornerRadius: 20)
    }
}

// MARK: - Document Scanner View

struct DocumentScannerView: View {
    @State private var scanner = DocumentScanner()
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📄 Scanner").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Scan button
            Button { scanner.startScan() } label: {
                VStack(spacing: 6) {
                    if scanner.isScanning {
                        ProgressView().tint(.white)
                        Text("Scanning...").font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                    } else {
                        Image(systemName: "doc.viewfinder").font(.system(size: 28)).foregroundStyle(.blue)
                        Text("Tap to Scan").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    }
                }.frame(maxWidth: .infinity).padding(.vertical, 20).innerGlass(cornerRadius: 14)
            }.buttonStyle(.plain)
            
            // Scanned docs
            if !scanner.scannedDocuments.isEmpty {
                VStack(spacing: 3) {
                    ForEach(scanner.scannedDocuments) { doc in
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill").font(.system(size: 14)).foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(doc.name).font(.system(size: 10, weight: .medium)).foregroundStyle(.white)
                                Text("\(doc.pageCount) page • \(doc.size)").font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
                            }
                            Spacer()
                            Text(doc.date, style: .relative).font(.system(size: 7)).foregroundStyle(.white.opacity(0.2))
                        }.padding(8).innerGlass(cornerRadius: 6)
                    }
                }
            }
        }.padding(20).frame(width: 340).glassBackground(cornerRadius: 24)
    }
}
