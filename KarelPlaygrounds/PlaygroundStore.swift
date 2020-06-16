//
//  PlaygroundStore.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/25/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import SwiftUI
import Combine

//View model that acts as a "store" of all the Karel playgrounds in the app.
class PlaygroundStore: ObservableObject {
    let name: String
    
    private var autosave: AnyCancellable?
    
    @Published private var playgroundNames = [PlaygroundViewModel:String]()
    
    init(named name: String = "Karel Playgrounds") {
        self.name = name
        let defaultsKey = "KarelPlaygroundStore.\(name)"
        playgroundNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: defaultsKey))
        autosave = $playgroundNames.sink { names in
            UserDefaults.standard.set(names.asPropertyList, forKey: defaultsKey)
        }
    }
    
    //retrieves the name of a playground if it exists in the store dictionary
    func name(for playground: PlaygroundViewModel) -> String? {
        if let name = playgroundNames[playground] {
            return name
        } else {
            return nil
        }
    }

    //given a playground's name, updates that playground in the store dictionary by replacing the old playground with the new given one
    func updatePlayground(_ playground: PlaygroundViewModel, name: String) {
        playgroundNames[playground] = name
    }
    
    //adds a playground to the dictionary
    func addPlayground(named name: String = "Untitled") {
        playgroundNames[PlaygroundViewModel()] = name
    }
    
    //removes a playground from the store dictionary
    func removePlayground(_ playground: PlaygroundViewModel) {
        playgroundNames[playground] = nil
    }
    
    //sets the name of a playground when it is changed
    func setName(_ name: String, for playground: PlaygroundViewModel) {
        playgroundNames[playground] = name
    }
    
    //array of all the available playgrounds in the store
    var playgrounds: [PlaygroundViewModel] {
        playgroundNames.keys.sorted { playgroundNames[$0]! < playgroundNames[$1]! }
    }
}


//Based on Lecture 8
extension Dictionary where Key == PlaygroundViewModel, Value == String {
    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }
    
    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String:String] ?? [:]
        for uuid in uuidToName.keys {
            self[PlaygroundViewModel(id: UUID(uuidString: uuid))] = uuidToName[uuid]
        }
    }
}
