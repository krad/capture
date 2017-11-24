import XCTest
@testable import captureCore
import PerfectNet

class WebServerTests: XCTestCase {

    func test_that_we_can_create_a_webserver_and_make_a_connection() {
        
        let server = try? Webserver(port: 3000)
        XCTAssertNotNil(server)
        
        try? server?.start()
        
        let client = NetTCP()
        let e = self.expectation(description: "Connecting to our webserver")
        try? client.connect(address: "0.0.0.0", port: 3000, timeoutSeconds: 5) { sock in
            sock?.write(string: "GET /") { _ in
                
                sock?.readSomeBytes(count: 1024) { respBytes in
                    XCTAssertNotNil(respBytes)
                    XCTAssertNotEqual(0, respBytes?.count)
                    e.fulfill()
                }
                
            }
        }
        
        self.wait(for: [e], timeout: 4.0)
    }
    
}
