# bC! x TPOLM: zebrain

Source code for the 4k intro "zebrain" by bC! & TPOLM.

See [dist/README.md](../blob/master/dist/README.md) for more details.

## Prerequisites

1. Matlab R2019a or newer.
2. Matlab Image Processing Toolbox (absolutely necessary) (needed only to run)
3. [zopfli](https://github.com/google/zopfli) installed (we found one with `npm install node-zopfli`)

## Running

1. Change MATLAB current directory to `src/`
2. Run `demo`
3. Alternatively, run `demo_dbg`, with the options as described in [dist/README.md](../blob/master/dist/README.md)

## Build

1. Change MATLAB current directory to `src/`
2. `build` should build `dist/zebrain.p`
3. `build(true)` should build all different versions of the demo.
4. `archive` should build everything and zip everything into `zebrain.zip`

## License

[MIT](../blob/master/LICENSE)