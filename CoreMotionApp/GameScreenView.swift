//
//  ContentView.swift
//  CoreMotionApp
//
//  Created by Hlwan Aung Phyo on 10/17/24.
//

import SwiftUI
import CoreMotion

final class MotionManager: NSObject, ObservableObject {
    @Published var isStarted :Bool = false
    @Published var maxX :Double = 0.0
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    var threadHold:Double = 10
    
    var rotationThreshold :Double = 0.02
    
//    @Published var transition:CGSize = .zero
    @Published var finalTransition:CGSize = .zero
    
    let motionManager = CMMotionManager()
    
    
    func startAccelerationSensor(){
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = 0.9
            
            
            motionManager.startDeviceMotionUpdates(to: .main) {[weak self] motionData, error in
                if error != nil{
                    return
                }
                
                guard let motionData = motionData else{
                    return
                }
                
                if motionData.userAcceleration.y > self?.maxX ?? 0{
                    self?.maxX = motionData.userAcceleration.y
                }
            }
        }
    }
    
    func startGeoMotionSensor(){
        if motionManager.isGyroAvailable{
            motionManager.deviceMotionUpdateInterval = 0.9
            motionManager.startGyroUpdates(to: .main) { gyroData, error in
                if error != nil{
                    return
                }
                
                guard let gyroData = gyroData else {
                    return
                }
                
                self.updateMotionData(gyroData: gyroData)
            }
        }
    }
    
    func stop(){
        isStarted = false
        motionManager.stopGyroUpdates()
    }
    
    private func updateMotionData(gyroData: CMGyroData) {
//        self.transition.width = gyroData.rotationRate.y * 60
//        self.transition.height = gyroData.rotationRate.x * 60
        // Ignore small x movements
        
        let rotationX = abs(gyroData.rotationRate.x) > rotationThreshold ? gyroData.rotationRate.x : 0
        
        // Ignore small y movements
        let rotationY = abs(gyroData.rotationRate.y) > rotationThreshold ? gyroData.rotationRate.y : 0


        
        self.x = rotationX
        self.y = rotationY
        
        // Update height
        let newHeight = finalTransition.height + rotationX * threadHold
        withAnimation {
            
            if newHeight >= 500{
                
                self.finalTransition.height = 500
                
            }else if newHeight <= -280{
                self.finalTransition.height = -280
            }else{
                self.finalTransition.height = newHeight
            }
        }
        // Update width
        let newWidth = finalTransition.width + rotationY * threadHold
        
        withAnimation {
            if newWidth >= 200{
                self.finalTransition.width = 200
            }else if newWidth <= -200{
                self.finalTransition.width = -200
            }else{
                self.finalTransition.width = newWidth
            }
            
        }
    }
}



struct GameScreenView: View {
    @ObservedObject var motionManager: MotionManager = MotionManager()
    @State var text:Double = 0
    @State var applePosition:CGSize = .zero
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {

            ZStack{
                RoundedRectangle(cornerRadius: 40)
                    .frame(width: 100,height: 100)
                    .shadow(radius: 4,x:4,y:4)
                    .offset(x:motionManager.finalTransition.width,y: motionManager.finalTransition.height)
                
                
                Image(.apple)
                    .resizable()
                    .frame(width: 50,height: 50)
                    .offset(y:applePosition.height)
                    .border(Color.red,width: 1)
            }
                
            
            
            
                   // Collision detection message
                   if isHit() {
                       Text("Hit!")
                           .font(.largeTitle)
                           .foregroundStyle(Color.red)
                   } else {
                       Text("No Hit")
                           .font(.largeTitle)
                           .foregroundStyle(Color.green)
                   }
            
            
            Text("\(motionManager.threadHold)")
                    .foregroundStyle(Color.orange)
#warning("change this to make game harder by time")
//                    .onReceive(timer) { output in
//                        motionManager.threadHold += 0.9
//                    }
                Button {
                    motionManager.stop()
                } label: {
                    Text("pause")
                        .foregroundStyle(Color.red)
                    
                }
                
                Button {
                    motionManager.startGeoMotionSensor()
                } label: {
                    Text("Start")
                        .foregroundStyle(Color.blue)
                }
            Text("X:\(motionManager.x)")
            Text("Y:\(motionManager.y)")
            Text("Z:\(motionManager.z)")
        }
        .padding()
    }
    func isHit() -> Bool {
        let rectangleSize = CGSize(width: 10, height: 10)  // Size of rectangle
        let appleSize = CGSize(width: 50, height: 50)  // Size of apple
        
        // Calculate the position of the rectangle based on its offset
        let rectangleX = motionManager.finalTransition.width
        let rectangleY = motionManager.finalTransition.height
        
        // Check if the frames overlap
        let hitX = abs(rectangleX - applePosition.width) < (rectangleSize.width + appleSize.width) / 2
        let hitY = abs(rectangleY - applePosition.height) < (rectangleSize.height + appleSize.height) / 2
        
        
        
        return hitX && hitY
    }
}

#Preview {
    GameScreenView()
}
