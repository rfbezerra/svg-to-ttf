# svg-to-ttf
A alpine based image to convert svg glyphs and generate TTF font using [fontcustom](https://github.com/rfbezerra/fontcustom).

This image includes:
* [Inkscape](https://inkscape.org/)
* [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
* [parallel](https://www.gnu.org/software/parallel/)
* [Fontcustom](https://github.com/FontCustom/fontcustom)

## Volumes
This image defines 2 volumes:
* /fonts/input - Input directory with svg glyphs
* /fonts/build - Output directory containing generated files

## Environment Variables
These variables are exposed to use:
* SKIP_STROKE_TO_PATH - Will not convert svg from stroke to path (default 0)
* FONT_NAME - Name of the generated font (default to Unnamed)
* UID - UserId used for generation (default 0 (root))
* GID - GroupId used for generation (default 0 (root))

## Process
This image will copy all svg glyphs from /fonts/input to a temporary directory.

After that, if choose, all glyphs will be converted from stroke to path. Some fonts need this step, like [Feather](https://github.com/feathericons/feather).

Finally, [Fontcustom](https://github.com/FontCustom/fontcustom) is used to generate desired TTF font.

## Use
Simple use can be:
`docker run --rm -v MY_INPUT_DIR:/fonts/input -v MY_OUTPUT_DIR:/fonts/build rfbezerra/svg-to-ttf`

If you want to define font name:
`docker run --rm -v MY_INPUT_DIR:/fonts/input -v MY_OUTPUT_DIR:/fonts/build -e FONT_NAME=MY_FONT_NAME rfbezerra/svg-to-ttf`

If you want that the result of build respect your user:
`docker run --rm -v MY_INPUT_DIR:/fonts/input -v MY_OUTPUT_DIR:/fonts/build -e FONT_NAME=MY_FONT_NAME -e UID=$(id -u) -e GID=$(id -g) rfbezerra/svg-to-ttf`
(GID is optional)

If you dont need to convert stroke to path:
`docker run --rm -v MY_INPUT_DIR:/fonts/input -v MY_OUTPUT_DIR:/fonts/build -e FONT_NAME=MY_FONT_NAME -e UID=$(id -u) -e SKIP_STROKE_TO_PATH=1 rfbezerra/svg-to-ttf`


## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Thanks
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=6ZPRN6FTR8SKA&currency_code=USD&source=url)

If you want to buy me a :beer: :)
