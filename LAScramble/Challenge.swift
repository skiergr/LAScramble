//
//  Challenge.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import Foundation

struct Challenge: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let station: String
}
