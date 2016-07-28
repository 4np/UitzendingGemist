//
//  Array+Random.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 28/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension Array {
    func randomElement() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
