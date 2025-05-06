//
//  GalleryView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/6/25.
//

import SwiftUI

struct GalleryView: View {
    var body: some View {
        VStack {
            Text("📸 Gallery")
                .font(.largeTitle)
                .padding()

            Text("This is where photos from past games will be shown.")
                .padding()
            
            Spacer()
        }
        .navigationTitle("Gallery")
    }
}
