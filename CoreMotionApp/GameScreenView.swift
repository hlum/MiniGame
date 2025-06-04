//
//  ContentView.swift
//  CoreMotionApp
//
//  Created by Hlwan Aung Phyo on 10/17/24.
//

import SwiftUI
import CoreMotion
import Firebase

final class MotionManager: NSObject, ObservableObject {
    @Published var highestScore:Int = 0
    @Published var score:Int = 0{
        didSet{
            if score > highestScore{
                highestScore = score
            }
        }
    }
    @Published var isStarted :Bool = false
    @Published var maxX :Double = 0.0
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    var threadHold:Double = 13
    var showAlert : Bool = false
    var alertMessage :String = "BOOM"
    var rotationThreshold :Double = 0.05
    @Published var finalTransition:CGSize = .zero
//    CGSize(width: -250, height: 400)
    //    CGSize(width: -350, height: 450)
    
    let motionManager = CMMotionManager()
    

    
    
    private func gameLost(){
        showAlert = true
        SoundPlayer.shared.playSoundEffect(soundFileName: "explosion", fileType: "wav")
    }
    
    //    @Published var transition:CGSize = .zero
    
    func startAccelerationSensor(){
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = 0.9
            
            
            motionManager.startDeviceMotionUpdates(to: .init()) {[weak self] motionData, error in
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
        let rotationX = abs(gyroData.rotationRate.x) > rotationThreshold ? gyroData.rotationRate.x : 0
        
        // Ignore small y movements
        let rotationY = abs(gyroData.rotationRate.y) > rotationThreshold ? gyroData.rotationRate.y : 0
        
        
        
        self.x = rotationX
        self.y = rotationY
        
        // Update height
        let newHeight = finalTransition.height + rotationX * threadHold
        withAnimation {
            
            if newHeight >= 350{
                
                self.finalTransition.height = 400
                gameLost()
                stop()
                threadHold = 0.02
                
            }else if newHeight <= -350{
                self.finalTransition.height = -400
                gameLost()
                stop()
                threadHold = 0.02

            }else{
                self.finalTransition.height = newHeight
            }
        }
        // Update width
        let newWidth = finalTransition.width + rotationY * threadHold
        
        withAnimation {
            if newWidth >= 150{
                self.finalTransition.width = 250
                gameLost()
                stop()
                threadHold = 0.02

                
            }else if newWidth <= -150{
                self.finalTransition.width = -250
                gameLost()
                stop()
                threadHold = 0.02

                
            }else{
                self.finalTransition.width = newWidth
            }
            
        }
    }
}



class AppleManager:ObservableObject{
    @Published var appleSize:CGSize = CGSize(width:70 , height:70 )
    @Published var applePosition:CGSize = CGSize(
        width: Int.random(
            in: -150...160
        ),
        height: Int.random(
            in: -300...300
        )
    )

    @Published var isEating : Bool = false
    
    
    func moveApple(){
        let newAppleXPosition = Int.random(in: -150...160)
        let newAppleYPosition = Int.random(in: -300...300)
        DispatchQueue.main.async{
            self.applePosition = CGSize(width: CGFloat(newAppleXPosition), height: CGFloat(newAppleYPosition))
        }
        
    }
}



struct GameScreenView: View {
    
    @Binding var userName:String
    @Binding var showGameScreen:Bool
    @StateObject var soundPlayer:SoundPlayer = SoundPlayer()
    @Namespace var appleNamespace
    @ObservedObject var motionManager: MotionManager = MotionManager()
    @State var text:Double = 0
    @ObservedObject var appleManager:AppleManager = AppleManager()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    // Timer-related variables
    @State private var hitTimer: Timer?
    @State private var collisionDuration = 0.0
    @State private var isInCollision = true
    @State private var opacity:Double = 0.6
    @State private var gameStart:Bool = false //for on appear instruction
    var body: some View {
        VStack {

            ZStack{
                if isHit(){
                    Color.black.ignoresSafeArea().opacity(opacity)
                }else{
                    Color.black.ignoresSafeArea().opacity(0.5)
                }
                VStack{
                    Spacer()
                    Text(userName)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 40,weight: .bold))
                    Text("Highest Score: \(motionManager.highestScore)")
                        .foregroundStyle(Color.blue)
                        .font(.system(size: 40,weight: .bold))
                        .padding()
                        .background(Color.black)
                        .cornerRadius(20)
                        .padding()
                    
                    Spacer()
                        
                    Text("Score:\(motionManager.score)")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 40,weight: .bold))
                        .padding()
                        .background(Color.black)
                        .cornerRadius(20)
                        .padding()
                    Spacer()
                }
                .opacity(0.5)

                VStack{
                    ForEach(0..<7){ _ in
                        HStack{
                            Spacer()
                            Image(motionManager.showAlert ? .explosion : .tnt)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:130)
                                .padding()
                        }
                    }
                }
                VStack{
                    ForEach(0..<7){ _ in
                        HStack{
                            Image(motionManager.showAlert ? .explosion : .tnt)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:130)
                                .padding()
                            Spacer()

                        }
                    }
                }
                
                VStack{
                    HStack{
                        ForEach(1..<4){_ in
                            Image(motionManager.showAlert ? .explosion : .tnt)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:130)
                                .padding()
                        }
                    }

                    Spacer()
                }
                
                VStack{
                    Spacer()

                    HStack{
                        ForEach(1..<4){_ in
                            Image(motionManager.showAlert ? .explosion : .tnt)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:130)
                                .padding()
                        }
                    }

                }
                RoundedRectangle(cornerRadius: 40)
                    .frame(width: 100,height: 100)
                    .shadow(color:.black,radius: 13)
                    .shadow(color:.black,radius: 19)
                    .offset(x:motionManager.finalTransition.width,y: motionManager.finalTransition.height)
                    .onReceive(timer) { output in
                            motionManager.threadHold += 0.2
                        }

                
                
                Image(.apple)
                    .resizable()
                    .frame(width: appleManager.appleSize.width,height: appleManager.appleSize.height)
                    .offset(x:appleManager.applePosition.width,y:appleManager.applePosition.height)
                    .matchedGeometryEffect(id: "apple", in: appleNamespace)
                    
                if !gameStart{
                    ZStack{
                        Color.black.opacity(0.4).ignoresSafeArea()
                        Text("タッチしてゲームスタート")
                            .foregroundStyle(Color.white)
                            .font(.largeTitle)
                            .bold()
                    }
                    .onTapGesture {
                        gameStart = true
                        motionManager.startGeoMotionSensor()
                    }
                }
            }
            
           
                        
            .alert(
                isPresented: $motionManager.showAlert,
                content: {
                    Alert(
                        title: Text(
                            motionManager.alertMessage
                        ),
                        primaryButton: .default(Text("もう一回"), action: {
                            restartGame()
                        }),
                        secondaryButton:.destructive(Text("終了する"), action:{
                            motionManager.finalTransition = .zero
                            motionManager.stop()
                            let scoreData = ScoreData(userName: userName, score: motionManager.highestScore, date: Timestamp(date: Date()))
                            FirestoreManger.shared.storeScore(scoreData: scoreData)
                            showGameScreen = false
                        }
                    ))
            })
                
            
       
            
                  
            
            
 
        }
        .onAppear{
            Task{
                motionManager.highestScore = await FirestoreManger.shared.getHighestScoreForUSer(userName: userName)
            }
        }
        
    }
    
    func restartGame(){
        let scoreData = ScoreData(userName: userName, score: motionManager.highestScore, date: Timestamp(date: Date())
        )
        FirestoreManger.shared.storeScore(scoreData: scoreData)
        gameStart = false
        motionManager.finalTransition = .zero
        motionManager.score = 0
    }
    func isHit() -> Bool {
        
        let rectangleSize = CGSize(width: 10, height: 10)  // Size of rectangle(smaller to make it like eating)
        let appleSize = CGSize(width: 70, height: 70)  // Size of apple
        
        // Calculate the position of the rectangle based on its offset
        let rectangleX = motionManager.finalTransition.width
        let rectangleY = motionManager.finalTransition.height
        
        // Check if the frames overlap
        let hitX = abs(rectangleX - appleManager.applePosition.width) < (rectangleSize.width + appleSize.width) / 2
        let hitY = abs(rectangleY - appleManager.applePosition.height) < (rectangleSize.height + appleSize.height) / 2
        
        if hitX && hitY {
            if !isInCollision{
                startCollisionTimer()
            }
            DispatchQueue.main.async{
                isInCollision = true
            }
        }else{
            resetCollisionTimer()
            DispatchQueue.main.async{
                isInCollision = false
            }
        }
        return hitX && hitY
    }
    
    func startCollisionTimer() {
           resetCollisionTimer()  // Reset any existing timer
        DispatchQueue.main.async {
            hitTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                collisionDuration += 1.0
                soundPlayer.playSoundEffect(soundFileName: "soundEffect", fileType: "wav")
                if appleManager.appleSize.width > 30{
                    withAnimation {
                        opacity += 0.1
                        appleManager.appleSize.width -= 15
                        appleManager.appleSize.height -= 15
                    }
                }
//                print(collisionDuration)
                
                if collisionDuration >= 3 {
                    appleManager.moveApple()
                    motionManager.score += 1
                    opacity = 0.5
                    // Move apple after 5 seconds of continuous collision
                    appleManager.appleSize = CGSize(width:70 , height:70 )//reset the apple size
                    resetCollisionTimer()
                }
            }
           }
       }
       
       func resetCollisionTimer() {
           hitTimer?.invalidate()
               DispatchQueue.main.async {
                   hitTimer = nil
                   collisionDuration = 0.0
               }
       }
}

#Preview {
    GameScreenView(userName: .constant("aung"),showGameScreen: .constant(true))
}
