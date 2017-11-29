import Foundation
import Socket

let serverTag = "Server: capture Webserver 0.0.3"

let videoTag =
"""
<html>
<head><title>capture session</title></head>
<body><video controls="controls" src="out.m3u8"></video></body>
</html>
"""

struct HTTPRequest {
    let verb: HTTPVerb
    let path: String
    let protocolVersion: String
    let headers: [String: String]
}

struct HTTPResponse {
    let status: HTTPStatusCode
    let contentType: String
    let contentLength: Int
    let body: Any

    init(body: Data, path: String) {
        self.status        = .ok
        self.contentLength = body.count
        self.body          = body
        
        if let ext = path.components(separatedBy: ".").last {
            switch ext {
            case "m3u8": self.contentType = "application/x-mpegURL"
            case "mp4": self.contentType = "video/mp4"
            default:
                self.contentType = "text/html"
            }
        
        } else {
            self.contentType   = "text/html"
        }
    }
    
    init(body: String) {
        self.status         = .ok
        self.contentType    = "text/html"
        self.contentLength  = body.count
        self.body           = body
    }
    
    var headerPayload: String {
        return [self.status.body,
                "Content-Type: \(self.contentType)",
                "Content-Length: \(self.contentLength)"].joined(separator: "\n") + "\n\n"
    }
    
    var bodyPayload: Data? {
        if body is Data { return (body as! Data) }

        if let bodyStr = body as? String {
            let strBuf = [UInt8](bodyStr.utf8)
            return Data(bytes: strBuf)
        }
        
        return nil
    }
}

enum HTTPVerb: String {
    case GET    = "GET"
    case POST   = "POST"
    case UPDATE = "UPDATE"
    case DELETE = "DELETE"
}

enum HTTPStatusCode: Int {
    case ok                 = 200
    case notFound           = 404
    case interalServerError = 500
    
    var body: String {
        return "HTTP/1.1 \(self.rawValue) \(self.name)"
    }
    
    internal var name: String {
        switch self {
        case .ok:                 return "OK"
        case .notFound:           return "Not Found"
        case .interalServerError: return "Internal Server Error"
        }
    }
}


class Webserver {
    
    
    let port: Int
    let webRoot: URL
    private let listenSocket: Socket
    private let lockQ   = DispatchQueue(label: "webserver.lock.q")
    private var connectedSockets: [Int32: Socket] = [:]
    private var continueRunning: Bool = true
    
    init(port: Int, webRoot: URL = URL(fileURLWithPath: "/tmp")) throws {
        self.port                        = port
        self.webRoot                     = webRoot
        self.listenSocket                = try Socket.create()
        self.listenSocket.readBufferSize = 32768
    }
    
    func start() {
        let q = DispatchQueue.global(qos: .userInteractive)
        
        q.async {
            do {
                try self.listenSocket.listen(on: self.port)
                repeat {
                    let socket = try self.listenSocket.acceptClientConnection()
                    self.addNewConnection(socket: socket)
                } while self.continueRunning
            } catch let err {
                print("Error starting server:", err)
            }
        }
    }
    
    func stop() {
        self.continueRunning = false
        for (_, socket) in self.connectedSockets {
            socket.close()
        }
        
        self.listenSocket.close()
        self.connectedSockets.removeAll()
    }
    
    private func addNewConnection(socket: Socket) {
        self.lockQ.sync { self.connectedSockets[socket.socketfd] = socket }
        
        let q = DispatchQueue.global(qos: .default)
        
        q.async {
            do {
                if let cmd = try socket.readString() {
                    if let req = parseRequest(from: cmd) {
                        switch req.verb {
                        case .GET: self.serveFile(at: req.path, to: socket)
                        case .POST: self.nop()
                        case .UPDATE: self.nop()
                        case .DELETE: self.nop()
                        }
                    }
                }
            } catch let error {
                print("Error reading from socket:", error)
            }
        }
    }
    
    private func serveFile(at path: String, to socket: Socket) {
        do {
            if path == "/" {
                
                let response = HTTPResponse(body: videoTag)
                _ = try socket.write(from: response.headerPayload)
                if let payload = response.bodyPayload { _ = try socket.write(from: payload) }
                socket.close()
                
            } else {
                
                let strippedPath = String(path.dropFirst())
                let fileURL = self.webRoot.appendingPathComponent(strippedPath)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    
                    do {
                        let fileData = try Data(contentsOf: fileURL)
                        let response = HTTPResponse(body: fileData, path: strippedPath)
                        _ = try socket.write(from: response.headerPayload)
                        if let payload = response.bodyPayload { _ = try socket.write(from: payload) }
                        
                        socket.close()
                    } catch {
                        _ = try socket.write(from: "HTTP/1.1 500 Internal Server Error\n")
                        socket.close()
                    }
                    
                    
                } else {
                    _ = try socket.write(from: "HTTP/1.1 404 Not Found\n")
                    socket.close()
                }
                
            }
            
            
        } catch let error {
            print(error)
        }
    }
    
    private func nop() {
        // no operation.
    }
    
}

internal func parseRequest(from input: String) -> HTTPRequest? {
    let components  = input.components(separatedBy: "\n")
    if let mainComps = mainComps(from: components.first) {
        return HTTPRequest(verb: mainComps.0,
                           path: mainComps.1,
                           protocolVersion: mainComps.2,
                           headers: headersFrom(Array(components.dropFirst())))
    }
    
    return nil
}

private func mainComps(from firstLine: String?) -> (HTTPVerb, String, String)? {
    let comps = firstLine?.components(separatedBy: " ")
    if let verbStr = comps?.first {
        if let verb = HTTPVerb(rawValue: verbStr) {
            if let path = comps?[1] {
                if let prot = comps?.last {
                    return (verb, path, prot)
                }
            }
        }
    }
    return nil
}

private func headersFrom(_ requestComponents: [String]) -> [String: String] {
    var headers: [String: String] = [:]
    for headerLine in requestComponents {
        let headerComponents = headerLine.components(separatedBy: " ")
        guard let key = headerComponents.first, let value = headerComponents.last else { continue }
        let strippedKey = String(key.dropLast())
        headers[strippedKey] = value
    }

    return headers
}
