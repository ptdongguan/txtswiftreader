//
//  listbook.swift
//  Basic-Note
//
//  Created by patrick on 4/17/16.
//  Copyright © 2016 Smith-Lab. All rights reserved.
//

import Foundation
//
//  ViewController.swift
//  test
//
//  Created by patrick on 4/17/16.
//  Copyright © 2016 patrick. All rights reserved.
//

import UIKit
let gettotalnotify="gettoalnotify"
class listbookController: UIViewController {

    var pageIdx: Int?
    var tobook:Int?
    
    var rootPath = NSHomeDirectory()
  
    func UTF8ToGB2312(str: String) -> (NSData?, UInt) {
        let enc              = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        let data             = str.dataUsingEncoding(enc, allowLossyConversion: false)
        return (data, enc)
    }

    @IBOutlet weak var bookc: UILabel!
    
    deinit {
        print("deinit single page at index \(pageIdx)")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if txtPages.pageExists(tobook!,pageidx: pageIdx!) {
            self.bookc.text=txtPages.getPage(tobook!, pageidx: pageIdx!)
        }
        else {
            setpage();
        }
    }
    func setpage() {
            let path1 = NSBundle.mainBundle().pathForResource("ww", ofType: "txt")!
            txtPages.preparePage(path1, bookidx: tobook!, fontof: bookc.font, heightof: UIScreen.mainScreen().bounds.height){
                success in
                self.bookc.text=txtPages.getPage(self.tobook!, pageidx: self.pageIdx!)
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(gettotalnotify, object: self.pageIdx)
                }
            }
    }
    func gettotalpage()->Int{
        
        return 10;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

