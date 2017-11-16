//
//  State.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public enum State: Equatable, CustomStringConvertible {
    
    case initial
    case releasing(progress: CGFloat)
    case loading(isDragging: Bool)
    case finished
    
    public var description: String {
        switch self {
        case .initial: return "Inital"
        case .releasing(let progress): return "Releasing: \(progress)"
        case .loading(let isDragging): return "Loading: \(isDragging)"
        case .finished: return "Finished"
        }
    }
}

public func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.initial, .initial): return true
    case (.finished, .finished): return true
    case (.loading(let isDragging1), .loading(let isDragging2)) where isDragging1 == isDragging2: return true
    case (.releasing(let progress1), .releasing(let progress2)) where abs(progress1 - progress2) < 0.01: return true
    default: return false
    }
}

public typealias PullToRefreshState = State
