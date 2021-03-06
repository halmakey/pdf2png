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
    var error: NSError?

    print("pdf2png infile[page] outfile width height scale")
    exit(0)
}

func infoFromFileName(input:String) -> (String, Int) {
    let pageExp = try! NSRegularExpression(pattern: "(.*?)\\[(\\d+)\\]", options: .CaseInsensitive)
    let matches = pageExp.matchesInString(input, options: NSMatchingOptions(), range: NSMakeRange(0, input.characters.count))

    if matches.count == 0 {
        return (input, 0)
    } else {
        let filename = (input as NSString)
            .substringWithRange(matches.first!.rangeAtIndex(1))

        let page = Int((input as NSString)
            .substringWithRange(matches.last!.rangeAtIndex(2)))
        return  (filename, page!)
    }
}

enum PDFError : ErrorType {
    case FileNotFound
    case FileBroken
}

func pdf2png(inurl: NSURL, page: Int, outurl: NSURL, width: CGFloat, height: CGFloat, scale: CGFloat) throws {
    let data = NSData(contentsOfURL: inurl)
    if data == nil {
        throw PDFError.FileNotFound
    }

    let pdfImageRep = NSPDFImageRep(data: data!)
    if pdfImageRep == nil {
        throw PDFError.FileBroken
    }
    pdfImageRep?.currentPage = page

    let obounds = pdfImageRep!.bounds
    let owidth = (width == 0 ? obounds.width : width) * scale;
    let oheight = (height == 0 ? obounds.height : height) * scale;
    let bounds = NSRect(x: 0, y: 0, width: owidth, height: oheight)

    let ri = NSImage(size: bounds.size)
    ri.lockFocus()
    NSGraphicsContext.currentContext()?.imageInterpolation = .High
    NSGraphicsContext.currentContext()?.colorRenderingIntent = .AbsoluteColorimetric
    pdfImageRep?.drawInRect(bounds)

    let bitmapRep = NSBitmapImageRep(focusedViewRect: bounds)
    ri.unlockFocus()
    let pngData = bitmapRep?.representationUsingType(.NSPNGFileType, properties: [:])
    pngData?.writeToFile(outurl.path!, atomically: true)
}


let (infile, page) = infoFromFileName(Process.arguments[1])

let inurl = NSURL(fileURLWithPath: infile)
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
    try pdf2png(inurl, page: page, outurl: outurl, width: width, height: height, scale: scale)
} catch PDFError.FileNotFound {
    print("\(inurl.path!) not found.")
    exit(1)
} catch PDFError.FileBroken {
    print("\(outurl.path!) not broken.")
    exit(2)
}

