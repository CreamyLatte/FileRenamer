//
//  ContentView.swift
//  FileRenamer
//
//  Created by Eisuke KASAHARA on 2022/09/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject var modelData = ModelData()
    
    var body: some View {
        VStack {
            Text("FileRenamer")
                .font(.largeTitle)
                .padding()
            
            HStack {
                Text("Files in the laundry")
                    .font(.headline)
                Spacer()
                Button(action: {modelData.selectFiles.removeAll()}, label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Deselect all")
                    }
                    .foregroundColor(.red)
                })
            }
            if modelData.selectFiles.isEmpty {
                Spacer()
                Button("Select files", action: {
                    let openPanel = NSOpenPanel()
                    openPanel.allowsMultipleSelection = true
                    openPanel.canChooseDirectories = false
                    openPanel.canChooseFiles = true
                    if openPanel.runModal() == .OK {
                        modelData.selectFiles = openPanel.urls
                    }
                })
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    guard !providers.isEmpty else {
                        return false
                    }
                    for provider in providers {
                        let _ = provider.loadObject(ofClass: URL.self) { object, error in
                            if let url = object {
                                DispatchQueue.main.async {
                                    modelData.selectFiles.append(url)
                                }
                            }
                        }
                    }
                    return true
                }
                Spacer()
            } else {
                List {
                    ForEach(modelData.selectFiles, id: \.self) { fileURL in
                        let fileName = fileURL.lastPathComponent
                        if let encodeFileName = fileName.reEncoding(using: modelData.usingEncode, encoding: .utf8) {
                            Text(encodeFileName)
                        } else {
                            Text("Encode error. (before: \(fileName))")
                        }
                    }
                    .onDelete(perform: rowRemove)
                }
            }
            HStack {
                Picker("読み取りエンコード", selection: $modelData.usingEncodeIndex) {
                    ForEach(0..<modelData.encodingList.count, id: \.self) { encode in
                        Text(modelData.encodingList[encode].description)
                    }
                }
                .frame(maxWidth: 300)
                
                Spacer()
                
                Button(action: modelData.filesRename, label: {
                    Text("Rename")
                })
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 500.0, minHeight: 300.0)
    }
    func rowRemove(offsets: IndexSet) {
        modelData.selectFiles.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
