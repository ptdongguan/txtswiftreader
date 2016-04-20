//
//  ViewController.swift
//  SwiftyPDF
//
//  Created by prcela on 12/01/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit


class ReadController: UIViewController {
    var db:SQLiteDB!

    var url: NSURL?
    var tobook:Int?
    var pageController: UIPageViewController!
    var currentPageIdx: Int?
    private var barsHidden = true
    private var pendingPageIdx: Int?
    var bookmark:Int?
    var totalpage:Int?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbsContainerView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //获取数据库实例
        tobook=0;
        db = SQLiteDB.sharedInstance()
        //如果表还不存在则创建表
        db.execute("create table if not exists t_bookmark(bmid integer primary key,bookno integer,totalpage integer,bookmark integer,created integer)")
        let data = db.query("select * from t_bookmark where bookno="+String(tobook!))
        if data.count > 0 {
            let tbookmark = data[data.count - 1]
            bookmark = tbookmark["bookmark"] as? Int
            totalpage=tbookmark["totalpage"] as? Int
            print("now db :",tbookmark)
        } else {
            bookmark=1
            
        }
//        let path = NSBundle.mainBundle().pathForResource("sample", ofType: "pdf")!
//        url = NSURL(fileURLWithPath: path)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTotalPages:", name: gettotalnotify, object: nil)
        
    }
    
    func onTotalPages(notification: NSNotification)
    {
        let ttp = notification.object as! Int
        print("Tiles saved for page: \(ttp)")
        let data = db.query("select * from t_bookmark where bookno="+String(tobook!))
        if data.count > 0 {
            let tbookmark = data[data.count - 1]
            bookmark = tbookmark["bookmark"] as? Int
            totalpage=tbookmark["totalpage"] as? Int
            print("now db :",tbookmark)
        } else {
            bookmark=1
            
        }
    
    }
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let statusBarHeight = Config.prefersStatusBarHidden ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height
        
        navBarTopConstraint.constant = barsHidden ? -navBar.frame.size.height-statusBarHeight:0
        thumbsBottomConstraint.constant = barsHidden ? -thumbsContainerView.frame.size.height:0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "embed"
        {
            
            pageController = segue.destinationViewController as! UIPageViewController
            
            pageController.dataSource = self
            pageController.delegate = self
            
//            if PdfDocument.open(url: url!) != nil
//            {
//                if let pageDesc = PdfDocument.pagesDesc.first
//                {
                    let singlePageVC = storyboard!.instantiateViewControllerWithIdentifier("pdfPage") as! listbookController
                    singlePageVC.tobook=tobook
                    singlePageVC.pageIdx = bookmark//pageDesc.idx
                    
                    currentPageIdx = singlePageVC.pageIdx

                    pageController.setViewControllers([singlePageVC], direction: .Forward, animated: false, completion: nil)
            if totalpage == 0 {
                totalpage=singlePageVC.gettotalpage()
            }
            
            //                }
//            }
        }
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return Config.prefersStatusBarHidden
    }
    
    @IBAction func tap(sender: AnyObject)
    {
        barsHidden = !barsHidden
        
        let statusBarHeight = Config.prefersStatusBarHidden ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height
        
        navBarTopConstraint.constant = barsHidden ? -navBar.frame.size.height-statusBarHeight:0
        thumbsBottomConstraint.constant = barsHidden ? -thumbsContainerView.frame.height:0
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func done(sender: AnyObject)
    {
        dismissViewControllerAnimated(true) {
//            PdfDocument.close()
        }
    }
}

extension ReadController: UIPageViewControllerDataSource
{
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let singlePageVC = viewController as! listbookController
        if let idx = singlePageVC.pageIdx where idx < totalpage
        {
            let nextSinglePageVC = storyboard!.instantiateViewControllerWithIdentifier("pdfPage") as! listbookController
            nextSinglePageVC.tobook=tobook
            nextSinglePageVC.pageIdx = idx+1
            return nextSinglePageVC
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let singlePageVC = viewController as! listbookController
        if let idx = singlePageVC.pageIdx where idx > 1
        {
            let prevSinglePageVC = storyboard!.instantiateViewControllerWithIdentifier("pdfPage") as! listbookController
            prevSinglePageVC.tobook=tobook

            prevSinglePageVC.pageIdx = idx-1
            return prevSinglePageVC
        }
        return nil
    }
}

extension ReadController: UIPageViewControllerDelegate
{
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
    {
        if let vc = pendingViewControllers.last
        {
            pendingPageIdx = (vc as! listbookController).pageIdx
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if completed
        {
            for previousVC in previousViewControllers
            {
                if let singlePageVC = previousVC as? listbookController
                {
                    //                    singlePageVC.removeTilingView()
                    
//                    if let imageScrollView = singlePageVC.imageScrollView
//                    {
//                        imageScrollView.zoomScale = imageScrollView.minimumZoomScale
//                    }
                    
                }
            }
            
            currentPageIdx = pendingPageIdx
        }
    }
}
