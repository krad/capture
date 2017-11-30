import Foundation
import Buffie

public enum CommandLineToolError: Error {
    case noOptions
    case noFile
    case listInputs(options: HelpOptions)
    case fileExists
}

public struct HelpOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let printVideoInputs   = HelpOptions(rawValue: 1 << 0)
    public static let printAudioInputs   = HelpOptions(rawValue: 1 << 1)
    public static let printDisplayInputs = HelpOptions(rawValue: 1 << 2)
}

@available(macOS 10.11, *)
public class CommandLineTool {
    
    public var url: URL?
    
    public var container: MovieFileContainer = .mp4
    public var time: Int?
    public var quality: MovieFileQuality = .high
    public var forceOverwrite = false
    public var bitrate: Int?
    
    public var videoDeviceID: String?
    public var audioDeviceID: String?
    
    public var display: Display?
    public var captureType: CaptureType = []

    public var liveStream: Bool = false
    public var liveStreamType: HLSPlaylistType = .live
    
    public var webroot: String = "/tmp"
    public var webport: Int = 3000
    
    private var signalTrap: SignalTrap?

    internal var helpOptions: HelpOptions = []
    
    public init(_ arguments: [String] = CommandLine.arguments) throws {
        guard arguments.count > 1 else { throw CommandLineToolError.noOptions }
        self.parseOptions(arguments: arguments)
    }
    
    public func run() throws {
        guard self.helpOptions.isEmpty else {
            throw CommandLineToolError.listInputs(options: self.helpOptions)
        }
        
        if self.liveStream {
            try StreamingCaptureSession.run(webroot: self.webroot,
                                            port: self.webport,
                                            playlistType: self.liveStreamType,
                                            videoDeviceID: self.videoDeviceID,
                                            audioDeviceID: self.audioDeviceID,
                                            display: self.display)

        } else {
            try LocalCaptureSession.run(url: self.url,
                                        container: self.container,
                                        bitrate: self.bitrate,
                                        quality: self.quality,
                                        captureType: self.captureType,
                                        forceOverwrite: self.forceOverwrite,
                                        videoDeviceID: self.videoDeviceID,
                                        audioDeviceID: self.audioDeviceID,
                                        display: self.display,
                                        timeout: self.time)
        }
    }
    
    private func parseOptions(arguments: [String]) {
        var cargs = arguments.map { strdup($0) }
        repeat {
            let ch = getopt(Int32(arguments.count), &cargs, "lwsv:a:d:o:t:c:q:b:fhr:p:")
            if ch  == -1 { break }
            
            switch UnicodeScalar(Int(ch)).flatMap(Character.init) {
            case "t"?:
                self.time = (String(cString: optarg) as NSString).integerValue
                
            case "o"?:
                let file        = String(cString: optarg)
                self.url        = URL(fileURLWithPath: file)
                if let container = determineContainer(from: file) {
                    self.container = container
                }
                
            case "c"?:
                if let container = MovieFileContainer(rawValue: String(cString: optarg)) {
                    self.container = container
                }
                
            case "l"?:
                self.helpOptions.insert(.printVideoInputs)
                
            case "s"?:
                self.helpOptions.insert(.printAudioInputs)
            
            case "w"?:
                self.helpOptions.insert(.printDisplayInputs)
                
            case "v"?:
                self.videoDeviceID = String(cString: optarg)
                self.captureType.insert(.videoCapture)
                
            case "a"?:
                self.audioDeviceID = String(cString: optarg)
                self.captureType.insert(.audioCapture)
                
            case "d"?:
                let displayDeviceID = UInt32((String(cString: optarg) as NSString).intValue)
                self.display = Display.init(displayID: displayDeviceID)
                self.captureType.insert(.screenCapture)

            case "q"?:
                if let quality = MovieFileQuality(rawValue: String(cString: optarg)) {
                    self.quality = quality
                }
                
            case "b"?:
                self.bitrate = (String(cString: optarg) as NSString).integerValue
                
            case "f"?:
                self.forceOverwrite = true
                
            case "h"?:
                self.liveStream = true
            
            case "d"?:
                self.liveStreamType = .vod
                
            case "r"?:
                self.webroot = String(cString: optarg)
                
            case "p"?:
                self.webport = Int(String(cString: optarg))!
                
            default:
                break
            }
            
        } while (true)
        
        optind = 1 /// getopt is kinda hacky. Reset index so tests don't freak out
    }
    
}

@available (macOS 10.11, *)
internal func getCaptureDevice(for videoID: String?,
                               and audioID: String?,
                               or display: Display?,
                               with reader: AVReader) throws -> CaptureDevice
{
    var captureDevice: CaptureDevice
    
    if let videoDeviceID = videoID,
        let audioDeviceID = audioID
    {
        captureDevice = try Camera(videoDeviceID: videoDeviceID,
                                   audioDeviceID: audioDeviceID,
                                   reader: reader,
                                   controlDelegate: nil)
        
    } else if let display = display {
        captureDevice = try ScreenRecorder(display: display,
                                           audioDeviceID: audioID,
                                           reader: reader)
        
    } else {
        if let r = reader as? CameraOutputReader {
            r.captureType = [.videoCapture, .audioCapture]
        }
        captureDevice = try Camera(.back,
                                   reader: reader,
                                   controlDelegate: nil)
    }
    
    return captureDevice
}
