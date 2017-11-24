import Foundation
import PerfectNet

let videoTag =
"""
<html>
<head>
<title>capture session</title>
</head>
<body>
<video controls="controls" src="out.m3u8">
</video>
</body>
</html>
"""

class Webserver {
    
    let port: UInt16
    private var server: NetTCP
    
    init(port: UInt16) throws {
        self.port   = port
        self.server = NetTCP()
        try self.server.bind(port: port)
    }
    
    func start() throws {
        self.server.listen(backlog: 1024)
        try self.server.accept(timeoutSeconds: NetEvent.noTimeout,
                               callBack: onAccept)
    }
    
    private func onAccept(socket: NetTCP?) {
        guard let socket = socket else { return }
        
        socket.readSomeBytes(count: 2048, completion: { bytes in
            guard let ubytes = bytes else { return }
            
            if let cmd = self.readCommand(bytes: ubytes) {
                print(cmd)
                
                let components = self.commandComponents(cmd: cmd)
                if  let verb = components.first,
                    let path = components.last
                {
                    print("====", verb, path, components)
                    switch path {
                    case "/": socket.write(string: videoTag) { _ in print("LOL") }
                    default:
                        print(path)
                    }
                    
                }
            }
            
            
        })
    }
    
    private func readCommand(bytes: [UInt8]) -> String? {
        let data = Data(bytes)
        return String(data: data, encoding: .utf8)
    }
    
    private func commandComponents(cmd: String) -> [String] {
        return cmd.components(separatedBy: " ")
    }
    
}
