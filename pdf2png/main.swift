//
//  main.swift
//  pdf2png
//
//  Created by Ryo Kikuchi on 2016/03/01.
//  Copyright © 2016年 rubi3. All rights reserved.
//

import Foundation
import AppKit

if Process.arguments.count < 2 {
    print("pdf2png infile outfile width height scale")
    exit(0)
}

let inurl = NSURL(fileURLWithPath: Process.arguments[1])
let outurl = NSURL(fileURLWithPath: Process.arguments[2])

var width: CGFloat = 0, height: CGFloat = 0, scale: CGFloat = 1
if Process.arguments.count >= 5 {
    if let n = NSNumberFormatter().numberFromString(Process.arguments[3]) {
        width = CGFloat(n)
    }
    if let n = NSNumberFormatter().numberFromString(Process.arguments[4]) {
        height = CGFloat(n)
    }
}

if Process.arguments.count >= 6 {
    if let n = NSNumberFormatter().numberFromString(Process.arguments[5]) {
        scale = CGFloat(n)
    }
}

do {
    try pdf2png(inurl, outurl: outurl, width: width, height: height, scale: scale)
} catch PDFError.FileNotFound {
    print("\(inurl.path!) not found.")
    exit(1)
} catch PDFError.FileBroken {
    print("\(outurl.path!) not broken.")
    exit(2)
}
