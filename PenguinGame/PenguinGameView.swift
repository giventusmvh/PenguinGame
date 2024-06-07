//
//  ContentView.swift
//  PenguinGame
//
//  Created by Giventus Marco Victorio Handojo on 06/06/24.
//

import SwiftUI
import CoreMotion

//struct Obstacle: Identifiable {
//    let id = UUID()
//    var position: CGSize
//}

struct PenguinGameView: View {
    @ObservedObject var motionManager = MotionManager()
    @State private var penguinPosition: CGFloat = 0
    @State private var icebergHeight: CGFloat = 100.0
    @State private var icebergWidth: CGFloat = 700.0
    @State private var isJumping = false
    @State private var gameOver = false
    @State private var isFalling = false
    @State private var penguinOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            
            if gameOver {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Button(action: {
                        resetGame()
                    }) {
                        Text("Restart")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                VStack {
                    Text("Don't Slip")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.bottom,120)
                    
                    Spacer()
                    
                    VStack {
                        // Penguin
                        Image("penguin") // Replace with a penguin image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .offset(x: penguinPosition, y: isJumping ? -90 : isFalling ? penguinOffset : 0)
                            .animation(.easeInOut)
                            
                        
                        // Iceberg
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: icebergWidth, height: icebergHeight)
                            .overlay(
                                Rectangle().stroke(Color.blue, lineWidth: 4)
                            )
                    }
                    .frame(width: icebergWidth, height: icebergHeight + 50)
                    .onAppear {
                        motionManager.startAccelerometerUpdates()
                        startMeltingIceberg()
                    }
                    .onDisappear {
                        motionManager.stopAccelerometerUpdates()
                    }
                    .onChange(of: motionManager.x) { _ in
                        updatePenguinPosition()
                    }

                    Spacer()
                }
                .padding(.top,120)
            }
        }.onTapGesture {
            jump()
        }
    }

    func updatePenguinPosition() {
        let tiltSensitivity: CGFloat = 100.0
        let newX = penguinPosition + CGFloat(motionManager.x) * tiltSensitivity
        let maxX = (icebergWidth / 2) + 30// Half the iceberg width minus half the penguin width

        if abs(newX) < maxX {
            penguinPosition = newX
        } else {
            triggerFall()
        }
    }

    func jump() {
        if isJumping { return }
        isJumping = true
        
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isJumping = false
            }
        }
    }

    func startMeltingIceberg() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            if icebergWidth > 100 {
                icebergWidth -= 10
            } else {
                timer.invalidate()
                // Handle game over
                gameOver = true
            }
        }
    }

    func triggerFall() {
        isFalling = true
        withAnimation(.easeIn(duration: 250.0)) {
            penguinOffset = 300 // Fall distance
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            gameOver = true
        }
    }

    func resetGame() {
        penguinPosition = 0
        icebergHeight = 100.0
        icebergWidth = 700.0
        penguinOffset = 0
        isFalling = false
        gameOver = false
        motionManager.startAccelerometerUpdates()
        startMeltingIceberg()
    }
}

#Preview {
    PenguinGameView()
}
