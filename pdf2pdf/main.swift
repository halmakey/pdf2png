//
//  main.swift
//  pdf2pdf
//
//  Created by Ryo Kikuchi on 2016/11/02.
//  Copyright © 2016年 rubi3. All rights reserved.
//

import Foundation
import AppKit
import Quartz

if Process.arguments.count < 2 {
    var error: NSError?

    print("pdf2pdf infile[page] outfile")
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

func pdf2pdf(inurl: NSURL, page: Int, outurl: NSURL) throws {

}

let (infile, index) = infoFromFileName(Process.arguments[1])

let inurl = NSURL(fileURLWithPath: infile)
let outurl = NSURL(fileURLWithPath: Process.arguments[2])

do {
    let pdf = PDFDocument(URL: inurl)
    let page = pdf.pageAtIndex(index)
    try page.dataRepresentation().writeToURL(outurl, options: NSDataWritingOptions.AtomicWrite)
} catch {
    print("\(inurl.path!) failed.")
    exit(1)
}
