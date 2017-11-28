import Foundation
import Buffie
import AVFoundation

let version = "0.0.2"

internal func printProgramInfo() {
    print("\ncapture \(version) (https://www.krad.io)")
}

public func printUsage() {
    printProgramInfo()
    print("USAGE: capture [options]\n")
    print("OPTIONS:")
    print("  -o:\tPath to file where video should be written")
    print("  -l:\tLists available video devices on the system")
    print("  -v:\tVideo device to record from (use -l to get list of available devices.)")
    print("     \t(Uses first available device if not given)")
    print("  -s:\tLists available audio devices on the system")
    print("     \t(Uses first available device if not given)")
    print("  -a:\tAudio device to record from (use -s to get a list of available devices.)")
    if #available(macOS 10.11, *) {
        print("  -w:\tLists available displays on the system")
        print("  -d:\tDisplay device to record from (user -w to get a list of available displays.)")
    }
    print("  -h:\tStart a live stream.  Runs a web server on port 3000 with an HLS live stream")
    print("  -r:\tDirectory to use to store HLS segment files")
    print("  -p:\tPort start start web server for HLS live stream (Default: 3000)")
    print("  -c:\tSet the container format {mp4, mov, m4v}.")
    print("     \tUses the extension of outfile if this is not present.\n")
    print("  -t:\tRecording time in seconds")
    print("     \tWill record indefinitely if not present.\n")
    print("  -q:\tRecording quality {low, medium, high, veryhigh, highest}")
    print("  -b:\tDesired bitrate")
    print("  -f:\tOverwrite the outfile if it exists")
    print("\nEXAMPLE:\n  capture -o movie.mp4 -f -t 60\n")
}

public func printRunningMessage() {
    printProgramInfo()
    print("Recording.  Press Ctrl-C to finish")
}

public func printVideoDevices() {
    print("VIDEO:")
    for (id, name) in AVCaptureDevice.videoDevicesDictionary() {
        print("  \(id) - \(name)")
    }
    print("")
}

public func printAudioDevices() {
    print("AUDIO:")
    for (id, name) in AVCaptureDevice.audioDevicesDictionary() {
        print("  \(id) - \(name)")
    }
    print("")
}

@available (macOS 10.11, *)
public func printDisplayDevices() {
    print("DISPLAYS:")
    for display in Display.getAll() {
        print("  \(display.displayID) - \(display.name)")
    }
    print("")
}
