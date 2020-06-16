//
//  PlaygroundChooser.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/25/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI

//Initial view of the app. Uses a List to display all the Karel playgrounds that the user has created
//Allows for deleting, editing, and adding Karel playgrounds. The playgrounds are persistent.
struct PlaygroundChooser: View {
    @EnvironmentObject var store: PlaygroundStore
    
    @EnvironmentObject var orientation: DeviceOrientation
    
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.playgrounds) { playground in
                    NavigationLink(destination: KarelWorldView(viewModel: playground).environmentObject(self.orientation)
                        .navigationBarTitle(self.store.name(for: playground) ?? "" )) {
                            PlaygroundListView(editMode: self.$editMode, playground: playground)
                                .environmentObject(self.store)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { self.store.playgrounds[$0] }.forEach { playground in
                        self.store.removePlayground(playground)
                    }
                }
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(leading: Button(action: {
                self.store.addPlayground()
            }, label: {
                Image(systemName: "plus").imageScale(.large)
            }), trailing: EditButton()
            ).environment(\.editMode, $editMode)
        }
    }
}




