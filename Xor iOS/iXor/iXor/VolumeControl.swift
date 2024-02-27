//
//  VolumeControl.swift
//  Xanadoo
//
//  Created by Mario Rotz on 27.02.24.
//  Copyright © 2024 MarioRotz. All rights reserved.
//

import Foundation

enum Volume {
    case music(changed: Double)
    case sound(changed: Double)
}

protocol VolumeControl {
    func changed(value:Volume)
}

