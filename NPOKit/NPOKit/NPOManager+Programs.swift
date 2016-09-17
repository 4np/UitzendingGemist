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

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension NPOManager {
    // http://apps-api.uitzendinggemist.nl/series.json
    public func getPrograms(withCompletion completed: @escaping (_ programs: [NPOProgram]?, _ error: NPOError?) -> () = { programs, error in }) -> Request? {
        return self.fetchModels(ofType: NPOProgram.self, fromPath: "series.json") { programs, error in
            // filter programs based on whether or not they are available
            let availablePrograms = programs?.filter { $0.available == true }
            completed(availablePrograms, error)
        }
    }
    
    public func getDetails(forProgram program: NPOProgram, withCompletion completed: @escaping (_ program: NPOProgram?, _ error: NPOError?) -> () = { program, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(nil, .noMIDError)
            return nil
        }
        
        return self.getDetails(forProgramWithMID: mid, withCompletion: completed)
    }
    
    // http://apps-api.uitzendinggemist.nl/series/AT_2051232.json
    fileprivate func getDetails(forProgramWithMID mid: String, withCompletion completed: @escaping (_ program: NPOProgram?, _ error: NPOError?) -> () = { program, error in }) -> Request? {
        let path = "series/\(mid).json"
        return self.fetchModel(ofType: NPOProgram.self, fromPath: path, withCompletion: completed)
    }
    
    public func getFavoritePrograms(withCompletion completed: @escaping (_ programs: [NPOProgram]?, _ error: NPOError?) -> () = { programs, error in }) {
        self.getPrograms() { programs, error in
            guard let programs = programs else {
                completed(nil, error)
                return
            }
            
            let favoritePrograms = programs.filter { $0.favorite }
            completed(favoritePrograms, nil)
        }
    }
    
    public func getDetailedFavoritePrograms(withCompletion completed: @escaping (_ programs: [NPOProgram]?, _ errors: [NPOError]?) -> () = { programs, error in }) {
        do {
            // get favorite programs from realm
            let realm = try Realm()
            let favoritePrograms = realm.objects(RealmProgram.self).filter("favorite == true")

            // define the variables
            var programs = [NPOProgram]()
            var errors = [NPOError]()
            
            // create a dispatch group
            let group = DispatchGroup()
            
            // iterate over favorite programs
            for favoriteProgram in favoritePrograms {
                // make sure this program has a mid
                guard let mid = favoriteProgram.mid else {
                    continue
                }
                
                group.enter()

                self.getDetails(forProgramWithMID: mid) { program, error in
                    if let program = program {
                        programs.append(program)
                    } else if let error = error {
                        errors.append(error)
                    }
                    
                    group.leave()
                }
            }
            
            // done
            group.notify(queue: DispatchQueue.main) {
                let sortedPrograms = programs.sorted { $0.name < $1.name }
                completed(sortedPrograms.count > 0 ? sortedPrograms : nil, errors.count > 0 ? errors : nil)
            }
        } catch let error as NSError {
            completed(nil, [NPOError.modelMappingError(error.localizedDescription)])
        }
    }
}
