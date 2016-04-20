import Foundation
import UIKit

class StreamReader  {
    var db:SQLiteDB!
    let encoding : UInt
    let chunkSize : Int
    var onepageend:Bool=false;
    var nowlocation:Int
    var pagno:Int=0
    
    var fileHandle : NSFileHandle!
    let buffer : NSMutableData!
    let delimData : NSData!
    var atEof : Bool = false
    var calfont:UIFont
    var calheight:CGFloat
    var leftheight:CGFloat=0
    var bookno:Int
    
    init?(path: String,booknn:Int, fontof:UIFont,heightof:CGFloat,delimiter: String = "\n", encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        self.nowlocation=0;
        self.calfont=fontof;
        self.calheight=heightof
        self.bookno=booknn;
        
        //获取数据库实例
        db = SQLiteDB.sharedInstance()
        //如果表还不存在则创建表
        db.execute("create table if not exists t_bookmark(bmid integer primary key,bookno integer,totalpage integer,bookmark integer,created integer)")
        
        if let fileHandle = NSFileHandle(forReadingAtPath: path),
            delimData = delimiter.dataUsingEncoding(encoding),
            buffer = NSMutableData(capacity: chunkSize)
        {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            onepageend=true
            return nil
        }
        var range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
//            print("=============\n\n");
            let tmpData = fileHandle.readDataOfLength(chunkSize)
//            print("after read:",fileHandle.offsetInFile);
//            print("and now location:",nowlocation);
            if tmpData.length == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer, encoding: encoding)
                    
                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                onepageend=true;
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        }
        var linelength:Int=range.location
        // Convert complete line (excluding the delimiter) to a string:
        var line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
                            encoding: encoding)
//        print("line:",line);
//        print("range location:",range.location);
//        print("range length:",range.length);
        nowlocation=nowlocation+range.location + range.length;
//        print("before remove that line  length:",buffer.length)
        var thelinerect:CGRect=getlinerect(line as String!);
        if(thelinerect.height == leftheight) {
            linelength+=range.length
            onepageend=true
            
        }
        print("line heigh  and left ",thelinerect.height,leftheight)
        if(thelinerect.height>leftheight){
            onepageend=true;
            print("need cut: and location is:",linelength);
            while thelinerect.height>leftheight {
                linelength--;
                if(linelength==0){
                    onepageend=true
                    return "";
                }
                print("over one page and get now length",linelength)

                line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, linelength)),
                                encoding: encoding)
                if(line != nil){
                thelinerect=getlinerect(line as String!);
                    print("need cut left height:",thelinerect.height);
                }
            }
            print("over one page and get now length---->",linelength)

        }
        if(onepageend){
            buffer.replaceBytesInRange(NSMakeRange(0, linelength), withBytes: nil, length: 0)

        }else {
            leftheight-=thelinerect.height
            buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        }
        // Remove line (and the delimiter) from the buffer:
        print("left length:",buffer.length)
        return line as String?
    }
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }
    
    func getonepage()->[String]?{
        var plines = Array<String>()
        var onepagec:String;
        leftheight=calheight
        while !onepageend {
           let oneline=self.nextLine();
            if (oneline != nil){
                print("oneline:",oneline)
                plines.append(oneline!)
            }
            if(leftheight<20){
                onepageend=true;
            }
            if(!onepageend){
                continue;
            }
            print("begin save:",pagno);
                //save to page files.
                onepagec="";
                for(index,value) in EnumerateSequence(plines){
                    onepagec+=value+"\n";
                }
                pagno++;
            let filename=txtParser.cachedPagePath(bookno,pageIdx: pagno)+".txt";
                var flag: Bool
                do {
                    try onepagec.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
                    flag = true
                } catch _ {
                    flag = false
                }
                if flag {
                    print("save file to ",filename);

                } else {
                    print("fail..... save file to ",filename);
                }
            
                if(atEof){
                    break;
                } else {
                    plines.removeAll();
                    onepageend=false
                    leftheight=calheight
                }
            
        }
//        bmid integer primary key,bookno integer,totalpage integer,bookmark integer,created integer
        let data = db.query("select * from t_bookmark where bookno=\(bookno)")
        if data.count > 0 {
            print("bookmark data:", data);
            let sql="update t_bookmark set totalpage=\(pagno) where bookno=\(bookno)";
            db.execute(sql);
        } else {
            let sql="insert into t_bookmark(bookno,totalpage,bookmark,created) values(\(bookno),\(pagno),1,0)";
            db.execute(sql);
        }
        print("get lines",plines)
        return plines
        return nil
    }
  
    func getthatpage(ppidx:Int)->[String]?{
        var plines = Array<String>()
        var onepagec:String;
        leftheight=calheight
        while !onepageend {
            let oneline=self.nextLine();
            if (oneline != nil){
                print("oneline:",oneline)
                plines.append(oneline!)
            }
            if(leftheight<20){
                onepageend=true;
            }
            if(!onepageend){
                continue;
            }
            print("begin save:",pagno);
            //save to page files.
            onepagec="";
            for(index,value) in EnumerateSequence(plines){
                onepagec+=value+"\n";
            }
            pagno++;
            if pagno == ppidx {
                return plines;
            }
            if(atEof){
                break;
            } else {
                plines.removeAll();
                onepageend=false
                leftheight=calheight
            }
            
        }
        //        bmid integer primary key,bookno integer,totalpage integer,bookmark integer,created integer
        let data = db.query("select * from t_bookmark where bookno=\(bookno)")
        if data.count > 0 {
            print("bookmark data:", data);
            let sql="update t_bookmark set totalpage=\(pagno) where bookno=\(bookno)";
            db.execute(sql);
        } else {
            let sql="insert into t_bookmark(bookno,totalpage,bookmark,created) values(\(bookno),\(pagno),1,0)";
            db.execute(sql);
        }
        print("get lines",plines)
        return plines
    }
    
    
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
    
    func getlinerect(line:String) -> CGRect {
        let attributes = [NSFontAttributeName: calfont]
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let text: NSString = NSString(CString: line.cStringUsingEncoding(NSUTF8StringEncoding)!,
                                      encoding: NSUTF8StringEncoding)!
        var  rect:CGRect = text.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width, calheight), options: option, attributes: attributes, context: nil)
        rect.origin.x = 0
        rect.origin.y = 66
        
        var width:CGFloat = rect.size.width + 24
        var  height:CGFloat = rect.size.height + 80
        
        if width < 100 {
            width = 100
            rect.origin.x = 0
            rect.size.width = 100
        }
//        print("now sizeidisis :\n\n is is:\n\n",rect);
        return rect;
        //        其实动态获取字符串NSString的内容宽度高度最主要的还是API NSString类提供的一个方法：
        //        sizeWithFont: constrainedToSize
        //
        //        例如:
        //        CGSize feelSize = [feeling sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(190,200)];
        //        float feelHeight = feelSize.height;
        //        这样就可以根据自己定义的长高的最大限值来获取当前文本的size
    }
}