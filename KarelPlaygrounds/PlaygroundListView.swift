//
//  PlaygroundListView.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/25/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//View for how each playground is displayed in the list of playgrounds
//Title and dimensions (rows x columns) are displayed
//An edit button appears when edit mode is active, and when clicked it presents the PlaygroundEditor as a sheet
struct PlaygroundListView: View {
    
    @EnvironmentObject var store: PlaygroundStore
    @Binding var editMode: EditMode
    @State var playground: PlaygroundViewModel
    @State private var showPlaygroundEditor = false

    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.store.name(for: playground) ?? "")
                Text("\(String(self.playground.numRows)) rows x \(String(self.playground.numCols)) columns").foregroundColor(Color.gray)
            }
            Spacer()
            Text(self.editMode == .active ? "Edit" : "").foregroundColor(Color.blue) //Edit button only appears when edit mode is active
            .onTapGesture {
                if self.editMode == .active {
                    self.showPlaygroundEditor = true
                }
            }
        }
        .sheet(isPresented: self.$showPlaygroundEditor) {
            PlaygroundEditor(playground: self.$playground, isShowing: self.$showPlaygroundEditor)
            .environmentObject(self.store)
        }
        
    }
}


