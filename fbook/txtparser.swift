//
//  txtparser.swift
//  fbook
//
//  Created by patrick on 4/19/16.
//  Copyright © 2016 patrick. All rights reserved.
//

import UIKit

class txtParser: NSObject
{
    static var txtOpQueue = NSOperationQueue()
    static var bigQueue = NSOperationQueue()
    static var thumbnailsQueue = NSOperationQueue()
    static var tilesQueue = NSOperationQueue()
    private class func assureDirPathExists(path: String)
    {
        if !NSFileManager.defaultManager().fileExistsAtPath(path)
        {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    class func cachedPagesPath() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let pagesPath = "\(paths.first!)/pages"
        
        assureDirPathExists(pagesPath)
        
        return pagesPath
    }
    
    class func cachedPagePath(bookIdx: Int) -> String
    {
        let path = "\(cachedPagesPath())/\(bookIdx)"
        
        assureDirPathExists(path)
        return path
    }
    class func cachedPagePath(bookIdx:Int,pageIdx: Int) -> String
    {
        let bookpath=cachedPagePath(bookIdx);
        let path = "\(bookpath)/\(pageIdx)"
        
        assureDirPathExists(path)
        return path
    }
    
    class func cachedTilesPath(pageIdx: Int) -> String
    {
        let path = "\(cachedPagePath(pageIdx))/tiles"
        
        assureDirPathExists(path)
        return path
        
    }
    
    class func clearCachedFiles()
    {
        let fm = NSFileManager.defaultManager()
        do {
            let cachedPath = cachedPagesPath()
            let paths = try fm.contentsOfDirectoryAtPath(cachedPath)
            for path in paths
            {
                try fm.removeItemAtPath("\(cachedPath)/\(path)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

//    StreamReader(path: path1,booknn:0,fontof: bookc.font,heightof: bookc.frame.height)
//    (path: String,booknn:Int, fontof:UIFont,heightof:CGFloat,delimiter: String = "\n", encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096)
    class func createTxt(path: String,booknn:Int, fontof:UIFont,heightof:CGFloat, completion: (success: Bool)->Void)
    {
        
        let op = txtOperation(path:path,booknn:booknn,fontof:fontof,heightof:heightof);
        op.completion = {success,lines in
            
//            
//            let pagePath = ImageCreator.cachedPagePath(pageIdx)
//            
//            let imageData = UIImagePNGRepresentation(image)
//            let path = "\(pagePath)/placeholder.png"
//            imageData?.writeToFile(path, atomically: false)
//            print("placeholder created for page \(pageIdx)")
            completion(success: success)
        }
        txtOpQueue.addOperation(op)
    }
    
}