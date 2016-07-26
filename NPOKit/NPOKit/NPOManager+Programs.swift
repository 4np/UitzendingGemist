//
//  NPOManager+Programs.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

extension NPOManager {
    // http://apps-api.uitzendinggemist.nl/series.json
    public func getPrograms(withCompletion completed: (programs: [NPOProgram]?, error: NPOError?) -> () = { programs, error in }) -> Request? {
        return self.fetchModels(ofType: NPOProgram.self, fromPath: "series.json") { programs, error in
            // filter programs based on whether or not they are available
            let availablePrograms = programs?.filter { $0.available == true }
            completed(programs: availablePrograms, error: error)
        }
    }
    
    public func getDetails(forProgram program: NPOProgram, withCompletion completed: (program: NPOProgram?, error: NPOError?) -> () = { program, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(program: nil, error: .NoMIDError)
            return nil
        }
        
        return self.getDetails(forProgramWithMID: mid, withCompletion: completed)
    }
    
    // http://apps-api.uitzendinggemist.nl/series/AT_2051232.json
    private func getDetails(forProgramWithMID mid: String, withCompletion completed: (program: NPOProgram?, error: NPOError?) -> () = { program, error in }) -> Request? {
        let path = "series/\(mid).json"
        return self.fetchModel(ofType: NPOProgram.self, fromPath: path, withCompletion: completed)
    }
    
    public func getFavoritePrograms(withCompletion completed: (programs: [NPOProgram]?, error: NPOError?) -> () = { programs, error in }) {
        self.getPrograms() { programs, error in
            guard let programs = programs else {
                completed(programs: nil, error: error)
                return
            }
            
            let favoritePrograms = programs.filter { $0.favorite }
            completed(programs: favoritePrograms, error: nil)
        }
    }
    
    public func getDetailedFavoritePrograms(withCompletion completed: (programs: [NPOProgram]?, errors: [NPOError]?) -> () = { programs, error in }) {
        do {
            // get favorite programs from realm
            let realm = try Realm()
            let favoritePrograms = realm.objects(RealmProgram.self).filter("favorite == true")

            // define the variables
            var programs = [NPOProgram]()
            var errors = [NPOError]()
            
            // create a dispatch group
            let group = dispatch_group_create()
            
            // iterate over favorite programs
            for favoriteProgram in favoritePrograms {
                // make sure this program has a mid
                guard let mid = favoriteProgram.mid else {
                    continue
                }
                
                dispatch_group_enter(group)

                self.getDetails(forProgramWithMID: mid) { program, error in
                    if let program = program {
                        programs.append(program)
                    } else if let error = error {
                        errors.append(error)
                    }
                    
                    dispatch_group_leave(group)
                }
            }
            
            // done
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                let sortedPrograms = programs.sort { $0.name < $1.name }
                completed(programs: sortedPrograms.count > 0 ? sortedPrograms : nil, errors: errors.count > 0 ? errors : nil)
            }
        } catch let error as NSError {
            completed(programs: nil, errors: [NPOError.ModelMappingError(error.localizedDescription)])
        }
    }
}
