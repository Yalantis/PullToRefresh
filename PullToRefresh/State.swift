//
//  State.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public enum State: Equatable, CustomStringConvertible {
    
    case Initial
    case Releasing(progress: CGFloat)
    case Loading
    case Finished
    
    public var description: String {
        switch self {
        case .Initial: return "Inital"
        case .Releasing(let progress): return "Releasing:\(progress)"
        case .Loading: return "Loading"
        case .Finished: return "Finished"
        }
    }
}

public func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.Initial, .Initial): return true
    case (.Loading, .Loading): return true
    case (.Finished, .Finished): return true
    case (.Releasing, .Releasing): return true
    default: return false
    }
}