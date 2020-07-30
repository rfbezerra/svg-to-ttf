#!/bin/sh

CMD_LINE="docker run --rm -v "\""\${PWD}"\"":/fonts rfbezerra/svg-to-ttf"

helpFunction()
{
   echo ""
   echo "Usage: ${CMD_LINE} [OPTIONS]"
   echo -e "\t-g, --gid [GID]              GroupId owner of the destination folder; default is equal to uid"
   echo -e "\t-i, --input [FOLDER]         Folder where svg glyphs lives; default is ./input"
   echo -e "\t-n, --name FONT_NAME         Name of the generated font"
   echo -e "\t-o, --output [FOLDER]        Destination folder for generated fonts; default is ./FONT_NAME"
   echo -e "\t-s, --skip_conversion        Skip the conversion from stroke to path"
   echo -e "\t-u, --uid [UID]              UserId owner of the destination folder; default is 0 (root)"
   echo -e "\t-h, --help                   Show this help message"
   exit 1 # Exit script after printing help
}

prepareFunction()
{
  mkdir -p "${OUTPUT_FOLDER}"
  TEMP_FOLDER=$(mktemp -d temp.XXXXXX)
  cp "${INPUT_FOLDER}/"*.svg "${TEMP_FOLDER}"
}

convertFunction()
{
  echo "Converting icons to paths"
  CMD="/usr/bin/parallel --bar /usr/bin/inkscape {} \
    --actions="\""select-all;object-to-path;export-overwrite;export-do"\"" ::: ${TEMP_FOLDER}/*.svg"
  AUTHFILE=$(mktemp -p /tmp Xauthority.XXXXXX)
  XAUTHORITY=$AUTHFILE /usr/bin/Xvfb :2020 -screen 0 640x480x24 -nolisten tcp >> /dev/null 2>&1 &
  XVFBPID=$! && DISPLAY=:2020 ${CMD} && kill ${XVFBPID}
}

buildFunction()
{
  echo "Generating font"
  /usr/bin/fontcustom compile "${TEMP_FOLDER}" \
    --font-name="${FONT_NAME}" \
    --output="${OUTPUT_FOLDER}" \
    --quiet \
    --force \
    --no-hash 2> /dev/null
}

cleanUpFunction()
{
  chown ${UID}:${GID} -R "${OUTPUT_FOLDER}"
  rm -rf "${TEMP_FOLDER}"
  rm .fontcustom-manifest.json
}

while [ $# -gt 0 ]; do
  case "$1" in
    --input*|-i*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      INPUT_FOLDER="${1#*=}"
      ;;
    --output*|-o*)
      if [[ "$1" != *=* ]]; then shift; fi
      OUTPUT_FOLDER="${1#*=}"
      ;;
    --name*|-n*)
      if [[ "$1" != *=* ]]; then shift; fi
      FONT_NAME="${1#*=}"
      ;;
    --uid*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi
      UID="${1#*=}"
      ;;
    --gid*|-g*)
      if [[ "$1" != *=* ]]; then shift; fi
      GID="${1#*=}"
      ;;
    --skip_conversion|-s)
      SKIP_CONVERSION="1"
      ;;
    --help|-h)
      helpFunction
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$FONT_NAME" ]
then
   echo "Font name is obrigatory";
   helpFunction
fi

INPUT_FOLDER="${INPUT_FOLDER:-./input}"
OUTPUT_FOLDER="${OUTPUT_FOLDER:-${FONT_NAME}}"
UID="${UID:-0}"
GID="${GID:-${UID}}"
SKIP_CONVERSION="${SKIP_CONVERSION:-0}"

prepareFunction
if [ "${SKIP_CONVERSION}" != "1" ]; then convertFunction; fi
buildFunction
cleanUpFunction
