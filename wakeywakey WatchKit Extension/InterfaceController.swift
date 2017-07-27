//
//  InterfaceController.swift
//  wakeywakey WatchKit Extension
//
//  Created by Nathan Chan on 7/24/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import WatchKit
import Foundation
import JumpingJacker

class InterfaceController: WKInterfaceController {

    var jumpingJacker: JumpingJacker = JumpingJacker(movementSensitivity: .normal)
    var successCount: Int = 0
    
    @IBOutlet var jumpingJacksCountLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        jumpingJacker.delegate = self
        jumpingJacker.start()
        
        DispatchQueue.main.async {
            WKInterfaceDevice.current().play(.start)
        }
    }
}

extension InterfaceController: JumpingJackerDelegate {
    func jumpingJackerDidJumpingJack(_ jumpingJacker: JumpingJacker) {
        
        successCount += 1
        DispatchQueue.main.async {
            self.jumpingJacksCountLabel.setText(String(describing: self.successCount))
        }
        
        if successCount >= 10 {
            DispatchQueue.main.async {
                WKInterfaceDevice.current().play(.stop)
            }
        } else {
            DispatchQueue.main.async {
                WKInterfaceDevice.current().play(.success)
            }
        }
    }
    
    func jumpingJacker(_ jumpingJacker: JumpingJacker, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}
