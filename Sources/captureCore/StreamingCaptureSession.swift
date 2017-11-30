import Foundation
import Buffie

@available (macOS 10.11, *)
class StreamingCaptureSession {
    
    static func run(webroot: String,
                    port: Int,
                    playlistType: HLSPlaylistType,
                    videoDeviceID: String?,
                    audioDeviceID: String?,
                    display: Display?) throws
    {
        let webrootURL = URL(fileURLWithPath: webroot)
        let webserver  = try Webserver(port: port, webRoot: webrootURL)
        webserver.start()
        print("Webserver running at http://0.0.0.0:\(port)")
        
        let writer        = try FragmentedMP4Writer(webrootURL)
        let reader        = LiveReader() { sample, type in writer.got(sample, type: type) }
        let captureDevice = try getCaptureDevice(for: videoDeviceID,
                                                 and: audioDeviceID,
                                                 or: display,
                                                 with: reader)
        
        /// This is what get's called when it's time to shutdown the program.
        let stopFunction = {
            print("Shutting down webserver...")
            webserver.stop()
            print("Finishing up...")
            captureDevice.stop()
        }
        
        // Trap sigint signals and trigger cleanup when they're spotted.
        let signalTrap = SignalTrap(SIGINT, onTrap: stopFunction)
        
        captureDevice.start()
    
        dispatchMain()
    }
    
}
