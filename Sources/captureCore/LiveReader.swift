import Foundation
import Buffie
import CoreMedia

class LiveReader: AVReader {
    var callback: (CMSampleBuffer, SampleType) -> Void
    init(callback: @escaping (CMSampleBuffer, SampleType) -> Void) {
        self.callback = callback
    }
    
    override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        self.callback(sample, type)
    }
}
