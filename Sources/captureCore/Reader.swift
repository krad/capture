import Foundation
import AVFoundation
import Buffie

public struct CaptureType: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public func areConditionsMet(videoFormat: CMFormatDescription?, audioFormat: CMFormatDescription?) -> Bool {
        if self == [.videoCapture] && videoFormat != nil                                        { return true }
        if self == [.videoCapture, .audioCapture] && videoFormat != nil && audioFormat != nil   { return true }
        if self == [.screenCapture, .audioCapture] && videoFormat != nil && audioFormat != nil  { return true }
        if self == [.screenCapture] && videoFormat != nil                                       { return true }
        return false
    }
    
    public static let videoCapture  = CaptureType(rawValue: 1 << 0)
    public static let audioCapture  = CaptureType(rawValue: 1 << 1)
    public static let screenCapture = CaptureType(rawValue: 1 << 2)
}


public class CameraOutputReader: AVReader {
    
    var fileWriter: MovieFileWriter?
    var container: MovieFileContainer
    var quality: MovieFileQuality
    var url: URL
    var bitrate: Int?
    var setupCalled = false
    var captureType: CaptureType
    
    public init(url: URL,
                container: MovieFileContainer,
                bitrate: Int?,
                quality: MovieFileQuality,
                captureType: CaptureType = [.videoCapture, .audioCapture])
    {
        self.url            = url
        self.container      = container
        self.bitrate        = bitrate
        self.quality        = quality
        self.captureType    = captureType
        super.init()
    }
    
    final public override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        guard self.captureType.areConditionsMet(videoFormat: self.videoFormat, audioFormat: self.audioFormat) else { return }
        
        if let writer = self.fileWriter {
            if writer.isWriting {
                writer.write(sample, type: type)
            }
        } else {
            if setupCalled == false {
                self.setupWriter(with: self.videoFormat, and: self.audioFormat)
            }
        }
    }
    
    final public func stop(_ cb: @escaping () -> Void) {
        self.fileWriter?.stop() { cb() }
    }
    
    private func setupWriter(with videoFormat: CMFormatDescription?,
                             and audioFormat: CMFormatDescription?) {
        guard let videoFormat = videoFormat else { return }
        self.setupCalled = true
        do {
            switch self.container {
            case .mp4:
                self.fileWriter = try MP4Writer(url,
                                                videoFormat: videoFormat,
                                                quality: self.quality,
                                                videoBitrate: self.bitrate,
                                                audioFormat: audioFormat)
            case .m4v:
                self.fileWriter = try M4VWriter(url,
                                                videoFormat: videoFormat,
                                                quality: self.quality,
                                                videoBitrate: self.bitrate,
                                                audioFormat: audioFormat)
            case .mov:
                self.fileWriter = try MOVWriter(url,
                                                videoFormat: videoFormat,
                                                quality: self.quality,
                                                videoBitrate: self.bitrate,
                                                audioFormat: audioFormat)
            }
            
            self.fileWriter?.start()
            
        } catch {
            self.setupCalled = false
            print("Couldn't create movie file writer")
            exit(-1)
        }
    }
}

