//
//  PdfPage.swift
//  SwiftyPDF
//
//  Created by prcela on 15/01/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class txtPages: NSObject
{

    
   class func pageExists(bookidx:Int,pageidx:Int) -> Bool
    {
        let path = txtParser.cachedPagePath(bookidx,pageIdx: pageidx) + ".txt"
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }

    
    class func preparePage(path:String,bookidx:Int,fontof:UIFont,heightof:CGFloat, completion: (success: Bool)->Void)
    {
        if !pageExists(bookidx,pageidx:1)
        {
            
            txtParser.createTxt(path, booknn: bookidx, fontof: fontof, heightof: heightof, completion: completion)
        }
    }
    class func getPage(bookidx:Int,pageidx:Int)->String?{
        let path:String = txtParser.cachedPagePath(bookidx,pageIdx: pageidx)+".txt";
        if let addfr = DDFileReader.init(filePath:path) {
            var rtext:String=""
            while let line=addfr.readLine() {
                rtext+=(line as String)+"\n"
            }
            return rtext;
        }
        return nil
    }
}
