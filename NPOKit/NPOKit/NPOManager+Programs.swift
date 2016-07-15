//
//  NPOManager+Programs.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension NPOManager {
    // http://apps-api.uitzendinggemist.nl/series.json
    public func getPrograms(withCompletion completed: (programs: [NPOProgram]?, error: NPOError?) -> () = { programs, error in }) {
        self.fetchModels(ofType: NPOProgram.self, fromPath: "series.json") { programs, error in
            // filter programs based on whether or not they are available
            let availablePrograms = programs?.filter { $0.available == true }
            completed(programs: availablePrograms, error: error)
        }
    }
    
    // http://apps-api.uitzendinggemist.nl/series/AT_2051232.json
    public func getDetails(forProgram program: NPOProgram, withCompletion completed: (program: NPOProgram?, error: NPOError?) -> () = { program, error in }) {
        guard let mid = program.mid else {
            completed(program: nil, error: .NoMIDError)
            return
        }
        
        let path = "series/\(mid).json"
        self.fetchModel(ofType: NPOProgram.self, fromPath: path, withCompletion: completed)
    }
}
