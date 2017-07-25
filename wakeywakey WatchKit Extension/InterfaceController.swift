//
//  InterfaceController.swift
//  wakeywakey WatchKit Extension
//
//  Created by Nathan Chan on 7/24/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class InterfaceController: WKInterfaceController {

    let motionManager = CMMotionManager()
    var lastValueX: Double?
    var lastValueY: Double?
    var lastValueZ: Double?
    
    enum Direction {
        case Up, Down, Unknown
    }
    var direction: Direction = .Unknown
    var intervalsSinceLastDirectionChange: Int = 0
    var successCount: Int = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        DispatchQueue.main.async {
            WKInterfaceDevice.current().play(.start)
        }
        
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.1
        
        let accelerometerQueue = OperationQueue()
        motionManager.startAccelerometerUpdates(to: accelerometerQueue) { (accelerometerData, err) -> Void in
            guard err == nil else
            {
                return
            }
            guard let data = accelerometerData else
            {
                return
            }
            let valueX = data.acceleration.x
            let valueY = data.acceleration.y
            let valueZ = data.acceleration.z
            if let lastValueX = self.lastValueX,
                let lastValueY = self.lastValueY,
                let lastValueZ = self.lastValueZ {
                let distance = sqrt(pow(lastValueX - valueX, 2) + pow(lastValueY - valueY, 2) + pow(lastValueZ - valueZ, 2))
                if distance > 1 && self.intervalsSinceLastDirectionChange > 3 {
                    if valueX + 0.5 < lastValueX {
                        // Up motion detected
                        if self.direction != .Up {
                            self.intervalsSinceLastDirectionChange = 0
                            self.direction = .Up
                        }
                    } else if valueX - 0.5 > lastValueX {
                        if self.direction != .Down {
                            if self.direction == .Up {
                                print("JUMPING JACK!!!!!!!!!!!!!!!!!!!!!!!!")
                                self.successCount += 1
                                DispatchQueue.main.async {
                                    if self.successCount >= 10 {
                                        WKInterfaceDevice.current().play(.stop)
                                    } else {
                                        WKInterfaceDevice.current().play(.success)
                                    }
                                }
                            }
                            self.intervalsSinceLastDirectionChange = 0
                            self.direction = .Down
                        }
                    }
                    print(distance)
                    print("Direction: \(String(describing: self.direction))")
                }
            }
            self.lastValueX = valueX
            self.lastValueY = valueY
            self.lastValueZ = valueZ
            self.intervalsSinceLastDirectionChange += 1
            //print("ACCE: \(valueX) \(valueY) \(valueZ)")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
