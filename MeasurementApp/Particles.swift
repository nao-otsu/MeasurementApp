//
//  Particles.swift
//  MeasurementApp
//
//  Created by 夏山聡史 on 2017/07/23.
//  Copyright © 2017年 夏山聡史. All rights reserved.
//

import Foundation
import SwiftRandom

class Particles {
    
    var X: Double
    var Y: Double
    var Vx: Double
    var Vy: Double
    var W: Double
    
    init() {
        X = 0.0
        Y = 0.0
        Vx = 0.0
        Vy = 0.0
        W = 0.0
    }
    
    func getX() -> Double{
        return X
    }
    
    func getY() -> Double{
        return Y
    }
    
    func getVx() -> Double{
        return Vx
    }
    
    func getVy() -> Double{
        return Vy
    }
    
    func getW() -> Double{
        return W
    }
    
    func setX(newX:Double){
        X = newX
    }
    
    func setY(newY:Double){
        Y = newY
    }
    
    func setVx(newVx:Double){
        Vx = newVx
    }
    
    func setVy(newVy:Double){
        Vy = newVy
    }
    
    func setW(newW:Double){
        W = newW
    }
    
}
