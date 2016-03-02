//
//  pdf.swift
//  pdf2png
//
//  Created by Ryo Kikuchi on 2016/03/01.
//  Copyright © 2016年 rubi3. All rights reserved.
//

import Foundation
import AppKit

enum PDFError : ErrorType {
    case FileNotFound
    case FileBroken
}

func pdf2png(inurl: NSURL, outurl: NSURL, var width: CGFloat, var height: CGFloat, scale: CGFloat) throws {
    let data = NSData(contentsOfURL: inurl)
    if data == nil {
        throw PDFError.FileNotFound
    }

    let pdfImageRep = NSPDFImageRep(data: data!)
    if pdfImageRep == nil {
        throw PDFError.FileBroken
    }

    let obounds = pdfImageRep!.bounds
    if width == 0 {
        width = obounds.width
    }
    width *= scale
    if height == 0 {
        height = obounds.height
    }
    height *= scale
    let bounds = NSRect(x: 0, y: 0, width: width, height: height)

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