//
//  MotionManager.swift
//  PenguinGame
//
//  Created by Giventus Marco Victorio Handojo on 06/06/24.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager: CMMotionManager
    @Published var x: Double = 0.0

    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 0.1
        startAccelerometerUpdates()
    }

    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.x = data.acceleration.y
                    }
                }
            }
        }
    }

    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}

