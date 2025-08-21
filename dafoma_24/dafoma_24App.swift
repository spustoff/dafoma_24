//
//  NeoCoder Road App
//  dafoma_24
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

@main
struct NeoCoderRoadApp: App {
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
