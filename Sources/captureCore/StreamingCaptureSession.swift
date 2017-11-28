import Foundation
import Buffie

class StreamingCaptureSession {
    
    static func run(webroot: String,
                    port: Int) throws
    {
        let webrootURL = URL(fileURLWithPath: webroot)
        let webserver  = try Webserver(port: port, webRoot: webrootURL)
        webserver.start()
        print("Webserver running at http://0.0.0.0:\(port)")
        
//        let writer    = try FragmentedMP4Writer(webrootURL)
//        let reader    = LiveReader() { sample, type in writer.got(sample, type: type) }
        
        dispatchMain()
    }
    
}
