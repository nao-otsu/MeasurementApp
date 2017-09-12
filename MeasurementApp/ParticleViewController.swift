//
//  ParticleViewController.swift
//  MeasurementApp
//
//  Created by 夏山聡史 on 2017/07/23.
//  Copyright © 2017年 夏山聡史. All rights reserved.
//

import UIKit
import SwiftRandom
import Charts

class ParticleViewController: UIViewController {
    
   
    @IBOutlet weak var lineChartView: LineChartView!
    
    var particles = [Particles]()
    var dataEntry: [BarChartDataEntry] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Particle")
        for i in 0...999{
            let particle = Particles()
            particle.X = Randoms.randomDouble(-50,50)
            particle.Y = Randoms.randomDouble(-50,50)
            particle.Vx = Randoms.randomDouble(-0.5,0.5)
            particle.Vy = Randoms.randomDouble(-0.5,0.5)
            particles.append(particle)
            print("X:\(particles[i].getX())")
            print("Y:\(particles[i].getY())")
            print("Vx:\(particles[i].getVx())")
            print("Vy:\(particles[i].getVy())")
            dataEntry.append(BarChartDataEntry(x: (particles[i].getX()), y: particles[i].getY()))
        }
        //setCharts()
    }
    
    func setCharts(){
        
        let lineChartDataSet = LineChartDataSet(values: dataEntry, label: "X,Y")
        
        
        lineChartView.data = LineChartData(dataSet: lineChartDataSet)
        //lineChartDataSet.circleRadius = 1
        lineChartDataSet.circleColors = [UIColor(red: 0/255, green: 204/255, blue: 255/255, alpha: 1)]

        lineChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
