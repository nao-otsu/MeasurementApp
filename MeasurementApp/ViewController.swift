//
//  ViewController.swift
//  MeasurementApp
//
//  Created by 夏山聡史 on 2017/07/16.
//  Copyright © 2017年 夏山聡史. All rights reserved.
//

import UIKit
import CoreMotion
import Charts
import RandomKit


class ViewController: UIViewController {
    
    @IBOutlet weak var scatterChartView: ScatterChartView!
    let cmManager = CMMotionManager()
    
    
    //グラフ用データ配列
    var dataEntry1: [ChartDataEntry] = []
    var dataEntry2: [ChartDataEntry] = []
    
    //正弦波用データ配列
    var sinx: [Double] = []
    var velocity: [Double] = []
    var accele: [Double] = []
    
    var particles = [Particles()]
    

    var m: Double = 0.0
    var i: Int = 0
    var k: Int = 0
    var num:Int = 999
    var l: Double = 1.25
    
    var timer = Timer()
    var timer1 = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...num {
            let particle = Particles()
            //推定値のX座標となる粒子を生成
            particle.setX(newX: Double.random(in: -0.5...0.5,using: &Xoroshiro.default))
            self.dataEntry2.append(ChartDataEntry(x: particle.getX(), y: 0.0))
            //推定値の各粒子の初速度は0とする
            particle.setVx(newVx: 0.0)
            //重み
            particle.W = 1 / Double(num + 1)
            particles.append(particle)
            print("\(particle.getX())")
        }
        
        //タイマー0.01秒間隔で呼び出し
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        //distance()
        
    }
    
    func update(){
        sinx.append(0.25 * sin(2.0 * Double.pi * 0.2 * m - Double.pi / 2))
        self.dataEntry1.append(ChartDataEntry(x: sinx[i], y: m))
        if i == 0{
            velocity.append(0.0)
            accele.append(0.0)
        } else {
            //真値計算
            velocity.append((sinx[i]-sinx[i-1])/0.01)
            accele.append((velocity[i]-velocity[i-1])/0.01)
//            print("velocity:\(velocity[i])")
//            print("accele:\(accele[i])")
        }
//        print("\(m):\(sinx[i])")
        i = i + 1
        m = m + 0.01
        
        if m < 5{
            self.setChart()
        } else if m > 5{
            timer.invalidate()
            timer1 = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.predict), userInfo: nil, repeats: true)
            
        }
    }
    
    func predict(){
        for j in 0...num{
            //加速度から速度と変位を予測
            particles[j].setVx(newVx: particles[j].getVx() + accele[k] * 0.01)
            let tmpX = particles[j].getX() + particles[j].getVx() * 0.01
            if tmpX > 0.5 {
                particles[j].setX(newX: 0.5)
            } else if tmpX < -0.5{
                particles[j].setX(newX: -0.5)
            } else {
            particles[j].setX(newX: tmpX)
            }
//                print("X:\(particles[j].getX())")
//                print("Vx:\(particles[j].getVx())")
        }

        if k == 125 {
            likelihood(value: 0.0)
        }else if k == 250 {
            likelihood(value: 0.25)
        }else if k == 375 {
            likelihood(value: 0.0)
        }else if k == 500 {
            likelihood(value: -0.25)
        }
        
        k = k + 1
        if k > 500 {
            //setChart()
            timer1.invalidate()
        }
        print("=================================\(k)")
    }
    
 
    
    func likelihood(value: Double){
        self.dataEntry2.removeAll()
        for index in 0...num{
            let distance = sqrt(pow(particles[index].getX()-value, 2)) * 100
            resampling(distance: distance,index: index)
        }
        setChart()
        l = l + 1.25
        
    }
    
    func resampling(distance: Double,index: Int){
        if distance > 3.0 {
            particles[index].setX(newX: 0.0)
            particles[index].setVx(newVx: 0.0)
        } else{
            print("X\(index):\(particles[index].getX())")
            print("Vx\(index):\(particles[index].getVx())")
        }
        self.dataEntry2.append(ChartDataEntry(x: particles[index].getX(), y: l))
        
    }
    
    
    func setChart(){
        
        let scatterChartDataSet1 = ScatterChartDataSet(values: dataEntry1, label: "Sin")
        
        let scatterChartDataSet2 = ScatterChartDataSet(values: dataEntry2, label: "estimate")
        
        scatterChartView.data = ScatterChartData(dataSets: [scatterChartDataSet1,scatterChartDataSet2])
        
        // 点の色
        scatterChartDataSet1.colors = [UIColor(red: 0/255, green: 204/255, blue: 255/255, alpha: 1)]
        scatterChartDataSet2.colors = [UIColor(red: 255/255, green: 102/255, blue: 153/255, alpha: 1)]
        scatterChartDataSet1.setScatterShape(ScatterChartDataSet.Shape.circle)
        scatterChartDataSet1.scatterShapeSize = 8.0
        scatterChartDataSet2.scatterShapeSize = 4.0
        
        // グラフの背景色
        scatterChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        scatterChartView.xAxis.axisMinimum = -0.5
        scatterChartView.xAxis.axisMaximum = 0.5
        
        
    }
    
    /*func distance(){
        
        
        
        //加速度取得
        cmManager.accelerometerUpdateInterval = 0.1
        cmManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            let motionData = data!
            let dt = self.cmManager.accelerometerUpdateInterval
            

            
            
        }
    }*/
    
    /*func sendUDP(){
         //UDP
         var addr = sockaddr_in(
         sin_len:    __uint8_t(MemoryLayout<sockaddr_in>.size),
         sin_family: sa_family_t(AF_INET),
         sin_port:   htons(value: 22222),
         sin_addr:   in_addr(s_addr: 0x0d01000a),
         sin_zero:   ( 0, 0, 0, 0, 0, 0, 0, 0 )
         )
        
        
         // UDP送信
         let textToSend: String = String(self.tmpVelocity)
         textToSend.withCString { cstr -> Void in
         let fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
         let sent = withUnsafePointer(to: &addr) {// ptr -> Void in
         
         let broadcastMessageLength = Int(strlen(cstr) + 1)
         //print("broadcastMessageLength:\(broadcastMessageLength)")
         
         let p = UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1)
         //print("p:\(p)")
         
         // Send the message
         let send = sendto(fd, cstr, broadcastMessageLength, 0, p, socklen_t(addr.sin_len))
         //print("send:\(send)")
         
         }
         close(fd)
         //print("Sent? \(sent)")
         }
         usleep(1000)
        
    }*/
    
    func htons(value: CUnsignedShort) -> CUnsignedShort {
        return (value << 8) + (value >> 8);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

