//
//  StartScreen.swift
//  CoreMotionApp
//
//  Created by Hlwan Aung Phyo on 10/30/24.
//

import SwiftUI
import FirebaseCore

struct StartScreenView: View {
    @State var userName: String = ""
    @State private var showHighscore = false
    @State private var showGameScreen = false
    
    var body: some View {
        ZStack {
            // Background with gradient and overlay
            LinearGradient(gradient: Gradient(colors: [Color.black,Color.black, Color.orange]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Main content
            VStack {
                
                // Game Title
                Text("Black Hole")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .orange, radius: 5, x: 0, y: 5)
                    .padding(.top, 100)
                
                
                Spacer()
                
                HStack{
                    Text("お名前")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                        .padding(.horizontal,60)
                    Spacer()
                }
                TextField("お名前を入力してください", text: $userName)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.horizontal,60)
            
                
                
                // Start Button
                Button(action: startGame) {
                    Text("Start")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height:80)
                    
                        .background(userName.isEmpty ? Color.gray : Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.vertical,50)
                }
                .disabled(userName.isEmpty)
                .padding(.horizontal,60)
                .scaleEffect(showGameScreen ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: showGameScreen)
                
                
                // Show Highscore Button
                Button(action: { showHighscore.toggle() }) {
                    Text("スコア表示")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height:80)
                        .background(Color.orange.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal,60)
                .sheet(isPresented: $showHighscore) {
                    HighscoreView()
                }
                
                Spacer()
                
                // Footer with animated glow effect
                Text("Get Ready for Adventure!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .shadow(color: .yellow, radius: 10, x: 0, y: 0)
                    .padding(.bottom, 50)
            }
            .fullScreenCover(isPresented: $showGameScreen) {
                GameScreenView(userName: $userName,showGameScreen:$showGameScreen)
            }
            .onAppear{
                SoundPlayer.shared.playBackgroundSound(soundFileName: "bcsound", fileType: "wav")
            }

        }
    }
    
    
    // MARK: - Button Actions
    private func startGame() {
        showGameScreen = true
    }
}


import SwiftUI

struct HighscoreView: View {
    @State var scores: [ScoreData] = []

    var body: some View {
        ZStack {
            // Light background to improve contrast with black sheet
            Color.white.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("High Scores")
                    .font(.largeTitle)
                    .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2)) // Dark Red accent
                    .padding(.top, 20)
                
                if scores.isEmpty {
                    // Loading text with a soft color
                    Text("Loading scores...")
                        .foregroundColor(Color.gray)
                        .padding(.top, 50)
                        .font(.title3)
                } else {
                    // List of scores with updated style
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(scores, id: \.userName) { scoreData in
                                HighscoreRow(scoreData: scoreData)
                                    .padding(.horizontal)
                                    .background(Color(red: 0.98, green: 0.95, blue: 0.9)) // Light beige background
                                    .cornerRadius(12)
                                    .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                scores = await FirestoreManger.shared.getAllScores()
            }
        }
    }
}

// Custom Row for each score with refined styling
struct HighscoreRow: View {
    let scoreData: ScoreData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scoreData.userName)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2)) // Dark Red
                
                Text("Score: \(scoreData.score)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Text("Date: \(formattedDate(scoreData.date))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
    }
    
    // Helper function to format the date
    private func formattedDate(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
#Preview {
    StartScreenView()
}
