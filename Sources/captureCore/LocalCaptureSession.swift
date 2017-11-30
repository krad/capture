import Foundation
import Buffie

@available (macOS 10.11, *)
class LocalCaptureSession {
    
    static func run(url: URL?,
                    container: MovieFileContainer,
                    bitrate: Int?,
                    quality: MovieFileQuality,
                    captureType: CaptureType,
                    forceOverwrite: Bool,
                    videoDeviceID: String?,
                    audioDeviceID: String?,
                    display: Display?,
                    timeout: Int?) throws
    {
        guard let url = url else { throw CommandLineToolError.noFile }
        
        if FileManager.default.fileExists(atPath: url.path) {
            if forceOverwrite { try FileManager.default.removeItem(atPath: url.path) }
            else              { throw CommandLineToolError.fileExists }
        }
        
        let reader = CameraOutputReader(url: url,
                                        container: container,
                                        bitrate: bitrate,
                                        quality: quality,
                                        captureType: captureType)


        let captureDevice = try getCaptureDevice(for: videoDeviceID,
                                                 and: audioDeviceID,
                                                 or: display,
                                                 with: reader)
        
        /// This is what get's called when it's time to shutdown the program.
        let stopFunction = {
            print("Finishing up...")
            //reader.stop() { exit(0) }
            captureDevice.stop()
        }

        // Trap sigint signals and trigger cleanup when they're spotted.
        let signalTrap = SignalTrap(SIGINT, onTrap: stopFunction)

        // Start the camera & recorder.  Let the user know we're running.
        captureDevice.start()
        printRunningMessage()
        
        // There was a timeout.  Schedule shutdown for timer
        if let timeout = timeout {
            let delayTime = DispatchTime.now() + .seconds(timeout)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                stopFunction()
            }
        }
        
        dispatchMain()
    }
    
}
