//
//  Obstacle.swift
//  FlappyUnicorn
//
//  Created by Iavor Dekov on 8/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Obstacle: CCSprite {
    
    func didLoadFromCCB() {
        position.y = genRandYObstaclePos()
    }
    
    func genRandYObstaclePos() -> CGFloat {
        return CGFloat(arc4random_uniform(408) + 80)
    }

}