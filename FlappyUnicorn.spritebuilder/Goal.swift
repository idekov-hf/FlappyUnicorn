//
//  Goal.swift
//  FlappyUnicorn
//
//  Created by Iavor Dekov on 8/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Goal: CCNode {
    
    func didLoadFromCCB() {
        physicsBody.sensor = true
    }

}