import XCTest
import CoreMedia
@testable import captureCore

class CaptureTypeTests: XCTestCase {

    func test_that_we_can_test_if_recording_requirements_are_met() {
        
        var videoFormat: CMFormatDescription? = nil
        var audioFormat: CMFormatDescription? = nil
        CMFormatDescriptionCreate(kCFAllocatorDefault, kCMMediaType_Video, fourCharCode(from: "avc1"), nil, &videoFormat)
        CMFormatDescriptionCreate(kCFAllocatorDefault, kCMMediaType_Audio, fourCharCode(from: "aac"), nil, &audioFormat)

        XCTAssertNotNil(videoFormat)
        XCTAssertNotNil(audioFormat)
        
        let videoOnly: CaptureType = [.videoCapture]
        XCTAssertTrue(videoOnly.areConditionsMet(videoFormat: videoFormat, audioFormat: nil))
        XCTAssertFalse(videoOnly.areConditionsMet(videoFormat: nil, audioFormat: audioFormat))
        
        let videoAudio: CaptureType = [.videoCapture, .audioCapture]
        XCTAssertTrue(videoAudio.areConditionsMet(videoFormat: videoFormat, audioFormat: audioFormat))
        XCTAssertFalse(videoAudio.areConditionsMet(videoFormat: videoFormat, audioFormat: nil))
        XCTAssertFalse(videoAudio.areConditionsMet(videoFormat: nil, audioFormat: audioFormat))
        
        let screenOnly: CaptureType = [.screenCapture]
        XCTAssertTrue(screenOnly.areConditionsMet(videoFormat: videoFormat, audioFormat: nil))
        XCTAssertFalse(screenOnly.areConditionsMet(videoFormat: nil, audioFormat: audioFormat))
        
        let screenAndAudio: CaptureType = [.screenCapture, .audioCapture]
        XCTAssertTrue(screenAndAudio.areConditionsMet(videoFormat: videoFormat, audioFormat: audioFormat))
        XCTAssertFalse(screenAndAudio.areConditionsMet(videoFormat: videoFormat, audioFormat: nil))
        XCTAssertFalse(screenAndAudio.areConditionsMet(videoFormat: nil, audioFormat: audioFormat))

    }
    
}

func fourCharCode(from str: String) -> FourCharCode {
    var string = str
    if string.unicodeScalars.count < 4 {
        string = str + "    "
    }
    
    //string = string.substringToIndex(string.startIndex.advancedBy(4))
    
    var res:FourCharCode = 0
    for unicodeScalar in string.unicodeScalars {
        res = (res << 8) + (FourCharCode(unicodeScalar) & 255)
    }
    
    return res
}
