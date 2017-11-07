# capture

`capture` is a command line utility for creating media files from various Audio/Video inputs.

You can use `capture` to create a movie file via the command line.

Current Supported Inputs:
  * FaceTime Camera
  * USB Webcams
  * HAL Audio Input Devices
  * Screens / Displays

## Usage

Run `capture` without any arguments to list all available options

```
capture 0.0.2 (https://www.krad.io)
USAGE: capture [options]

OPTIONS:
  -o:	Path to file where video should be written
  -l:	Lists available video devices on the system
  -v:	Video device to record from (use -l to get list of available devices.)
     	(Uses first available device if not given)
  -s:	Lists available audio devices on the system
     	(Uses first available device if not given)
  -a:	Audio device to record from (use -s to get a list of available devices.)
  -w:	Lists available displays on the system
  -d:	Display device to record from (user -w to get a list of available displays.)
  -c:	Set the container format {mp4, mov, m4v}.
     	Uses the extension of outfile if this is not present.

  -t:	Recording time in seconds
     	Will record indefinitely if not present.

  -q:	Recording quality {low, medium, high, veryhigh, highest}
  -b:	Desired bitrate
  -f:	Overwrite the outfile if it exists

EXAMPLE:
  capture -o movie.mp4 -f -t 60
```

## Installation

### Homebrew

_Coming Soon..._

### From source

```
git clone https://www.github.com/krad/capture.git capture
cd capture
swift build
```

## Dependencies

 * Swift 4.0
 * [Buffie](https://www.github.com/krad/Buffie)


## Examples

Below are some examples of how you can use `capture`

#### Screen Recording

First start by getting the Display ID of the screen you're interested in recording:
```
capture -w
```

You can record a screen to an output file like so:

```
capture -d 123456 -o screen.mp4 -f
```

You can also record a screen cast using an audio device.

Start by getting the audio device you're interested in recording from:
```
capture -s
```

Then just simply pass it as the audio (`-a`) flag
```
capture -d 123456 -a HALINPUTDEVICE123 -o screenSpeek.mp4 -f
```

#### Webcam recording

By default `capture` will use the first video and audio device available to capture input from.

You can create a movie simply by running:
```
capture -o hi.mp4
```

If you wish to use a specific camera or audio input you can obtain it's id by running:
```
capture -l -s
```

Then just pass the IDs you obtained to the command:
```
capture -v VID123 -a HALINPUTDEVICE123 -o hi.mp4
```
