# Zebrain

A 4k intro written in MATLAB. `zebrain.p` is the official version submitted to the competition, `zebrain_opt.p` is an alternative version that has options for running it windowed or for capturing a 60p video.

## How to run

1. Change Matlab current directory or add to path the location of `zebrain.p`
2. Run `zebrain`

The intro was written and tested on Matlab R2019a - win64. It may or may not work on any other platforms.

## Running with options

`zebrain_opt` provides a few options:

`zebrain_opt('capture',true)` captures the video and audio into .avi (Motion JPEG) and .wav files, respectively. They are placed into a newly create `output` directory in the current folder. Currently the only practical way to capture at a specific resolution is to change the resolution of the screen to the desired resolution e.g. 1920x1080. The capture & encoding takes some time.

To combine the .avi and .wav files, ffmpeg can be used with the following command line options: `ffmpeg -i output/video.avi -i output/audio.wav -c:v libx264 -c:a aac -movflags +faststart output/combined.mp4`

`zebrain_opt('capture',true,'fps',60)` capture at a specific fps (default: 60).

`zebrain_opt('window',[])` run the demo windowed, instead of full screen.

`zebrain_opt('start',pat)` start the demo from pattern `pat`, which should be from 0 to 34.

## How does it work

- The code was first made into a single file .m file, by concatenating functions in the end and inlining function calls.
- The code was minimized by a custom minimizer that used simple regexps to look for things that look like variables. The variables were given very short names, by doing simple string replaces in the code. The minifier was stupid as hell, so one had to avoid using short variable names like x which might also get replaced in somewhere where it should not be. Naturally, all whitespace was removed.
- One could then just use `pcode` and already get a reasonably small file: apparently MATLAB compresses p-code files somehow. This would get the demo near to 5k. Close, but not enough. Instead, we compressed the code into a .zip file, where the deflate-stream was optimized using zopfli (https://github.com/google/zopfli) and the headers written manually using MATLAB (one can drop the filename from the local file headers - they are redundant and no zip-decompressor we tested actually uses anything else than the filenames from the central directory). This got the code to around 3.7k.
- To make this zip file "self-runnable", zip-format is actually designed so that one can make self-extracting zip-files by adding executable code in the beginning. The file header locations and central directory locations will have to be updated, but otherwise it's as easy as prepending code in the front. So the final p-code file is actually a valid zip-file, just rename it to .zip and you should be able to look inside the archive.
- Luckily, MATLAB is not picky about appending data to the end of p-code files. So we generate p-code from the following script: `a=tempname;r=unzip(which(mfilename),a);run(r{1});rmdir(a,'s')` and appended the zip-file in the end. This basically unzips the script itself into a temporary directory, runs script `k` within the directory, and once the script is done, deletes the temporary directory.
- The overhead from pcode is 134 bytes, zip-file headers & directories adds another 101 bytes, so we have 247 bytes of overheads. All the rest is zopfli optimized DEFLATEd code. The overhead could be further pushed down by making the self executing script more dirty: for example, by hard coding the name of the script, or not using temporary directory, or by not deleting temporary files etc. This could further reduce the size of the pcode part, but would also make the script less robust.
- The visuals are one figure, created with `figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none','Pointer','custom','PointerShapeCData',nan(16,16));`
- We have four overlaying axes. The blurred images are computed on CPU and shown on the bottom axes. The 3D-objects (`patch`, `line`, `scatter3`...) are on the second axes. Third axes has a an alpha-blended image that creates the gradient to black in the corners. The top-most axes contains the texts (`text(x,y,z,...)`).
- The song was tracked with Soundbox (https://github.com/mbitsnbites/soundbox); we just ported the player to Matlab (https://github.com/vsariola/matsoundbox) 
- The track is rendered into a waveform, which played using `a=audioplayer(...);play(a)`. Current time we get from `a.currentSample`.
- While rendering the track, we save the sound envelopes for each channel. These envelopes are added to various places during the rendering of the demo.
- `drawnow` is used to refresh the screen.

Full write-up and source code will follow shortly.

## Credits

code: pestis/bC! 
music: distance/TPOLM
ascii: apollo/bC!

## Kudos

m/Bits'n'Bytes, who wrote Soundbox, the tracker used for the music
p01, whose write-ups about 4k development in javascript also helped and inspired methods how to write shorter code in MATLAB
all the authors of various javascript crunchers, whose ideas on polyglot png/html files inspired making the self-extracting p-files/.zip files
zopfli team at Google, whose tool was used to optimize the deflate streams in the zip
