import XCTest
import Socket
@testable import captureCore

class WebServerTests: XCTestCase {
    
    var server: Webserver?
    let port: Int32 = 3001
    
    override func setUp() {
        self.startServer()
    }
    
    override func tearDown() {
        self.stopServer()
    }

    func test_that_we_can_create_a_webserver_and_make_a_connection() {
        let client = try? Socket.create()
        XCTAssertNotNil(client)
        try? client?.connect(to: "0.0.0.0", port: self.port)
        
        let bytesWritten = try? client?.write(from: "GET /")
        XCTAssertEqual(5, bytesWritten!)
        
        let response = try? client?.readString()
        XCTAssertNotNil(response!)
        XCTAssertEqual("HTTP/1.1 200 OK\n\(videoTag)", response!)
    }
    
    func test_that_we_can_get_a_404() {
        let client = try? Socket.create()
        XCTAssertNotNil(client)
        try? client?.connect(to: "0.0.0.0", port: self.port)
        
        let bytesWritten = try? client?.write(from: "GET /blahblahblah")
        XCTAssertEqual(17, bytesWritten!)
        
        let response = try? client?.readString()
        XCTAssertNotNil(response!)
        XCTAssertEqual("HTTP/1.1 404 Not Found\n", response!)
    }
    
    func xtest_that_we_can_get_file_bodies() {
        
        let client = try? Socket.create()
        XCTAssertNotNil(client)
        try? client?.connect(to: "0.0.0.0", port: self.port)
        
        let bytesWritten = try? client?.write(from: "GET /out.m3u8")
        XCTAssertEqual(13, bytesWritten!)
        
        let playlistURL = URL(fileURLWithPath: fixturesPath() + "/out.m3u8")
        let playlist    = try? String(contentsOf: playlistURL)
        XCTAssertNotNil(playlist)
        
        let response = try? client?.readString()
        XCTAssertNotNil(response!)
        XCTAssertEqual("HTTP/1.1 200 OK\n\(playlist!)", response!)

    }
    
    func test_request_component_parsing() {
        
        let input =
"""
GET /out.m3u8 HTTP/1.1
Host: 0.0.0.0:3000
User-Agent: curl/7.54.0
Accept: */*

"""
        
        let result = parseRequest(from: input)
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result?.verb, .GET)
        XCTAssertEqual(result?.path, "/out.m3u8")
        XCTAssertEqual(result?.protocolVersion, "HTTP/1.1")
        XCTAssertNotNil(result?.headers)
        XCTAssertEqual(result?.headers["Host"], "0.0.0.0:3000")
        XCTAssertEqual(result?.headers["User-Agent"], "curl/7.54.0")
        XCTAssertEqual(result?.headers["Accept"], "*/*")
        
    }
    
    func startServer() {
        let webRoot = URL(fileURLWithPath: fixturesPath())
        self.server = try? Webserver(port: Int(self.port), webRoot: webRoot)
        XCTAssertNotNil(server)
        server?.start()
    }
    
    func stopServer() {
        self.server?.stop()
        self.server = nil
    }
    
}

func fixturesPath() -> String {
    let path = #file.split(separator: "/")
    return "/" + path[0..<path.count-1].joined(separator: "/") + "/Fixtures"
}
