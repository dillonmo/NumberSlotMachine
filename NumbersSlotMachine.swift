//
//  NumbersSlotMachine.swift
//  numbers-slot
//
//  Created by Sun Xi on 06/08/2017.
//  Copyright © 2017 xis. All rights reserved.
//

import Foundation
import UIKit

class NumbersSlotMachine: UIView {
    
    var incrementRoll = false
    var downRoll = false
    var charAnimationDuration = 0.3
    var lastInt: Int = 0
    var currentInt: Int = 0
    var waitingDict: [Int:[String]] = [:]
    
    var labels: [UILabel] = []
    
    var numberSlotQ: DispatchQueue!
    
    init() {
        super.init(frame: CGRect.zero)
        self.clipsToBounds = true
        self.numberSlotQ = DispatchQueue(label: "com.NumberSlotMachine.numberslotq")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setIntger(input: Int) {
        numberSlotQ.async {
            self.numberSlotQ.suspend()
            self.lastInt = self.currentInt
            self.currentInt = input
            //print ("lastInt: \(self.lastInt), currentInt: \(self.currentInt)")
            let currentStr = String(self.currentInt)
            let lastStr = String(self.lastInt)
            
            let currentIsLonger: Bool = currentStr.characters.count > lastStr.characters.count
            var enumLength: Int!
            if currentIsLonger {
                enumLength = currentStr.characters.count
            } else {
                enumLength = lastStr.characters.count
            }
            self.waitingDict.removeAll()
            
            for index in 0...enumLength-1 {
                var currentChar = ""
                var lastChar = ""
                if currentIsLonger {
                    let ind = currentStr.index(currentStr.startIndex, offsetBy: currentStr.characters.count-index-1)
                    currentChar = String(currentStr[ind])
                    if (index < lastStr.characters.count) {
                        let ind_last = lastStr.index(lastStr.startIndex, offsetBy: lastStr.characters.count-index-1)
                        lastChar = String(lastStr[ind_last])
                    }
                } else {
                    let ind = lastStr.index(lastStr.startIndex, offsetBy: lastStr.characters.count-index-1)
                    lastChar = String(lastStr[ind])
                    if (index < currentStr.characters.count) {
                        let ind_current = currentStr.index(currentStr.startIndex, offsetBy: currentStr.characters.count-index-1)
                        currentChar = String(currentStr[ind_current])
                    }
                }
                var array: [String] = []
                if (lastChar == "" || currentChar == "") {
                    array.append(currentChar)
                } else {
                    let currentDigit = Int(String(currentChar))
                    let lastDigit = Int(String(lastChar))
                    
                    if self.incrementRoll {
                        if let startInt = lastDigit, let endInt = currentDigit {
                            if (startInt < endInt) {
                                for i in startInt+1...endInt {
                                    array.append(String(i))
                                }
                            } else if (startInt > endInt) {
                                if (startInt < 9) {
                                    for i in startInt+1...9 {
                                        array.append(String(i))
                                    }
                                }
                                for i in 0...endInt {
                                    array.append(String(i))
                                }
                            }
                        }
                        //print ("array: \(array)")
                    } else {
                        if let startInt = lastDigit, let endInt = currentDigit {
                            if (startInt > endInt) {
                                for i in (endInt...startInt-1).reversed() {
                                    array.append(String(i))
                                }
                            } else if (startInt < endInt) {
                                if (startInt > 0) {
                                    for i in (0...startInt-1).reversed() {
                                        array.append(String(i))
                                    }
                                }
                                for i in (endInt...9).reversed() {
                                    array.append(String(i))
                                }
                            }
                        }
                    }
                }
                self.waitingDict[index] = array
            }
            
            DispatchQueue.main.async {
                self.startAnimation()
            }
        }
        
    }
    
    func startAnimation() {
        var currentStr = String(currentInt)
        var lastStr = String(lastInt)
        var currentIsLonger = currentStr.characters.count > lastStr.characters.count
        var enumLength: Int!
        if currentIsLonger {
            enumLength = currentStr.characters.count
        } else {
            enumLength = lastStr.characters.count
        }
        
        for i in 0...enumLength-1 {
            let array = waitingDict[i]!
            //print("array: \(array)")
            if (i >= self.labels.count) {
                let label = UILabel(frame: (CGRect(x: 0.0, y: 0.0, width: 20.0, height: 50.0)))
                label.center.x = frame.width - (CGFloat(i)+0.5)*label.bounds.size.width
                label.center.y = frame.height / 2
                label.font = UIFont(name: "Avenir", size: 18)
                label.textColor = .white
                self.labels.append(label)
                self.addSubview(label)
            }
            if array.count == 0 {continue}
            
            let label = labels[i]
            for (index, element) in array.enumerated() {
                //print ("array: \(index), \(element)")
                let l = UILabel(frame: label.bounds)
                l.font = UIFont(name: "Avenir", size: 18)
                l.textColor = .white
                l.text = String(element)
                
                if self.downRoll {
                    l.center = CGPoint(x: label.center.x, y: label.center.y - CGFloat(index+1)*l.bounds.size.height)
                } else {
                    l.center = CGPoint(x: label.center.x, y: label.center.y + CGFloat(index+1)*l.bounds.size.height)
                }
                self.addSubview(l)
                l.alpha = 0.0
                
                autoreleasepool(invoking: { () -> () in
                    UIView.animate(withDuration: self.charAnimationDuration*Double(array.count), delay: Double(i)*0.2, options: .curveEaseInOut, animations: {
                        if self.downRoll {
                            l.center = CGPoint(x: l.center.x, y: l.center.y+CGFloat(array.count)*l.bounds.size.height)
                        } else {
                            l.center = CGPoint(x: l.center.x, y: l.center.y-CGFloat(array.count)*l.bounds.size.height)
                        }
                        l.alpha = 1.0
                    }, completion: {(finished: Bool) in
                        //print ("completion")
                        l.removeFromSuperview()
                    })
                })
            }

            let oriCenter = label.center
            numberSlotQ.suspend()
            UIView.animate(withDuration: self.charAnimationDuration*Double(array.count), delay: Double(i)*0.2, options: .curveEaseInOut, animations: {
                if self.downRoll {
                    label.center = CGPoint(x: label.center.x, y: label.center.y+CGFloat(array.count)*label.bounds.size.height)
                } else {
                    label.center = CGPoint(x: label.center.x, y: label.center.y-CGFloat(array.count)*label.bounds.size.height)
                }
            }, completion: {(finished: Bool) in
                //print ("last completion")
                var str = ""
                if let last = array.last {
                    str = String(last)
                }
                label.text = str
                label.center = oriCenter
                self.numberSlotQ.resume()
                
            })
        }
        
        numberSlotQ.resume()

    }
    

}
