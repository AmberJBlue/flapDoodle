//
//  RandomFunc.swift
//  FlappyClone
//
//  Created by Amber Blue on 2/1/17.
//  Copyright © 2017 Amber Blue. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
}