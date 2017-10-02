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
import GameKit


class ViewController: UIViewController {
    
    @IBOutlet weak var scatterChartView: ScatterChartView!
    let cmManager = CMMotionManager()
    
    
    //グラフ用データ配列
    var dataEntry1: [ChartDataEntry] = []
    var dataEntry2: [ChartDataEntry] = []
    
    //正弦波用データ配列
    var sinx: [Double] = []
    var siny: [Double] = []
    var velocityX: [Double] = []
    var velocityY: [Double] = []
    var acceleX: [Double] = []
    var acceleY: [Double] = []
    
    var particles = [Particles()]
    

    var m: Double = 0.0
    var i: Int = 0
    var k: Int = 0
    var num:Int = 1999
    var l: Double = 1.25
    
    var timer = Timer()
    var timer1 = Timer()
    
    //ノイズ平均と標準偏差
    let mean: Double = 0.01
    let deviation: Double = 0.0009652
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...num {
            let particle = Particles()
            //推定値のX座標となる粒子を生成
            particle.setX(newX: Double.random(in: -0.5...0.5,using: &Xoroshiro.default))
            particle.setY(newY: Double.random(in: -0.5...0.5,using: &Xoroshiro.default))
            self.dataEntry2.append(ChartDataEntry(x: particle.getX(), y: particle.getY()))
            //推定値の各粒子の初速度は0とする
            particle.setVx(newVx: 0.0)
            particle.setVy(newVy: 0.0)
            //重み
            particle.W = 1 / Double(num + 1)
            particles.append(particle)
            //print("\(particle.getX())")
        }
        
        //タイマー0.01秒間隔で呼び出し
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        //distance()
        
    }
    
    func update(){
        siny.append(0.25 * sin(2.0 * Double.pi * 0.2 * m - Double.pi / 2))
        sinx.append(m * 0.1 - 0.25)
        self.dataEntry1.append(ChartDataEntry(x: sinx[i], y: siny[i]))
        if i == 0{
            velocityX.append(0.0)
            acceleX.append(0.0)
            velocityY.append(0.0)
            acceleY.append(0.0)
            predict()
        } else {
            //真値計算
            velocityX.append((sinx[i]-sinx[i-1])/0.01)
            acceleX.append((velocityX[i]-velocityX[i-1])/0.01)
            velocityY.append((siny[i]-siny[i-1])/0.01)
            acceleY.append((velocityY[i]-velocityY[i-1])/0.01)

            predict()
//            print("velocityX:\(velocityX[i])")
//            print("velocityY:\(velocityY[i])")
//            print("acceleX:\(acceleX[i])")
//            print("acceleY:\(acceleY[i])")
        }
//        print("\(m):\(sinx[i])")
        i = i + 1
        m = m + 0.01
        
        if m < 5{
            self.setChart()
        } else if m > 5{
            timer.invalidate()
            //timer1 = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.predict), userInfo: nil, repeats: true)
            
        }
    }
    
    func predict(){
//        let random = GKRandomSource()
        self.dataEntry2.removeAll()
        for j in 0...num{
            //加速度ノイズ
//            let noiseX = (1/sqrt(2*Double.pi)*deviation)*exp(-(pow(Double.random(in: -10.0...10.0,using: &Xoroshiro.default) - mean,2))/2*pow(deviation,2))
//            let noiseY = GKGaussianDistribution(randomSource: random, mean: 0.01, deviation: 0.0009652)
            //let noiseY = (1/sqrt(2*Double.pi)*deviation)*exp(-(pow(Double.random(in: -0.05...0.05,using: &Xoroshiro.default) - mean,2))/2*pow(deviation,2))
            
            //加速度のノイズ
            let noiseX = Double.random(in: -0.05...0.05,using: &Xoroshiro.default)
            let noiseY = Double.random(in: -0.05...0.05,using: &Xoroshiro.default)
            
            //加速度から速度と変位を予測
            particles[j].setVx(newVx: particles[j].getVx() + (acceleX[k] + noiseX) * 0.01)
            particles[j].setVy(newVy: particles[j].getVy() + (acceleY[k] + noiseY) * 0.01)
            
            //最大値と最小値を判定
            let tmpX = particles[j].getX() + particles[j].getVx() * 0.01
            if tmpX > 0.5 {
                particles[j].setX(newX: 0.5)
            } else if tmpX < -0.5{
                particles[j].setX(newX: -0.5)
            } else {
            particles[j].setX(newX: tmpX)
            }
            //最大値と最小値を判定
            let tmpY = particles[j].getY() + particles[j].getVy() * 0.01
            if tmpY > 0.5 {
                particles[j].setY(newY: 0.5)
            } else if tmpY < -0.5{
                particles[j].setY(newY: -0.5)
            } else {
                particles[j].setY(newY: tmpY)
            }
            
            self.dataEntry2.append(ChartDataEntry(x: particles[j].getX(), y: particles[j].getY()))
            
//                print("X:\(particles[j].getX())")
//                print("Vx:\(particles[j].getVx())")
        }
        
        if k == 125 {
            likelihood(valueX: -0.15,valueY: 0)
        }else if k == 250 {
            likelihood(valueX: 0,valueY: 0.25)
        }else if k == 375 {
            likelihood(valueX: 0.15,valueY: 0)
        }else if k == 500 {
            likelihood(valueX: 0.25,valueY: -0.25)
        }
        
        k = k + 1
        if k > 500 {
            //setChart()
            timer1.invalidate()
        }
        print("=================================\(k)")
    }
    
 
    
    func likelihood(valueX: Double,valueY: Double){
        self.dataEntry2.removeAll()
        //var weight: Double = 0.0
        var max: [Int] = []
        var maxIndex: [Int:Double] = [:]
        let distance0 = sqrt(pow(valueX, 2)+pow(valueY,2))
        for index in 0...num{
            let distance1 = sqrt(pow(particles[index].getX(), 2)+pow(particles[index].getY(),2))
            //let distance = (1/sqrt(2*Double.pi)*0.1)*exp(-(pow(distance1 - distance0,2))/2*pow(0.1,2))
            //particles[index].setW(newW: distance0/sqrt(pow((distance0-distance1), 2)))
            particles[index].setW(newW: (1/sqrt(2*Double.pi)*0.1)*exp(-(pow(distance1 - distance0,2))/2*pow(0.1,2)))
            
            //print(particles[index].getW())
            maxIndex[index] = particles[index].getW()


        }
        
        //重みの大きいインデックスの順番に入れ替える
        for (key, _) in maxIndex.sorted(by: {$0.1 > $1.1}){
                max.append(key)
        }

        
        
        resampling(Max: max)

    }

    func resampling(Max: [Int]){
        for index in 0...num {
            if particles[index].getW() < 0.039894{
                let randomValue = Int(arc4random_uniform(20))
                particles[index].setX(newX: particles[Max[randomValue]].getX())
                particles[index].setY(newY: particles[Max[randomValue]].getY())
            } else{
                //print("Y\(index):\(particles[index].getY())")
                //print("Vx\(index):\(particles[index].getVx())")
            }
            self.dataEntry2.append(ChartDataEntry(x: particles[index].getX(), y: particles[index].getY()))
        }
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
        scatterChartView.rightAxis.axisMaximum = 0.5
        scatterChartView.rightAxis.axisMinimum = -0.5
        scatterChartView.leftAxis.axisMaximum = 0.5
        scatterChartView.leftAxis.axisMinimum = -0.5
        
        
    }
    
    func distance(){
        
        
        
        //加速度取得
        cmManager.accelerometerUpdateInterval = 0.01
        cmManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            let motionData = data!
            let dt = self.cmManager.accelerometerUpdateInterval
            print(motionData.acceleration.x)
        }
    }
    
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

