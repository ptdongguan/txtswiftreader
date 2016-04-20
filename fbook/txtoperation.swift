//
//  PdfPageToImageOperation.swift
//  SwiftyPDF
//
//  Created by prcela on 15/01/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class txtOperation: NSOperation
{
    var path:String
    var booknn:Int
    var fontof:UIFont
    var heightof:CGFloat
    var completion: ((success: Bool,lines:[String])->Void)? = nil
    
    init(path: String,booknn:Int, fontof:UIFont,heightof:CGFloat)
    {
        self.path = path
        self.booknn = booknn
        self.fontof=fontof
        self.heightof=heightof;
        
        super.init()
    }
    
    override func main()
    {
        var ccc:String="";
        if let aStreamReader = StreamReader(path: path,booknn:booknn,fontof: fontof,heightof: heightof) {
            defer {
                aStreamReader.close()
            }
            let lines = aStreamReader.getonepage()
            dispatch_async(dispatch_get_main_queue()) {
                self.completion?(success: true,lines:lines!)
            }
        }
    }
    
}
