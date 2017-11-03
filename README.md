# capture

`capture` is a command line utility for creating media files from various system inputs.

You can use `capture` to create a movie from your webcam via the command line.

## Usage

Run `capture` without any arguments to list all available options

```
capture 0.0.1 (https://www.krad.io)
USAGE: capture [options]

OPTIONS:
  -o:	Path to file where video should be written
  -l:	Lists available video devices on the system
  -v:	Video device to record from (use -l to get list of available devices.)
     	(Uses first available device if not given)
  -w:	Lists available audio devices on the system
     	(Uses first available device if not given)
  -a:	Audio device to record from (use -w to get a list of available devices.)
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
