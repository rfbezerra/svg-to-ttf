#!/bin/sh

FONT_NAME="${FONT_NAME:-Unnamed}"
SKIP_STROKE_TO_PATH="${SKIP_STROKE_TO_PATH:-0}"

cd /fonts

TEMP_FOLDER=$(mktemp -d temp.XXXXXX)
cp ./input/*.svg "${TEMP_FOLDER}"
if [ "${SKIP_STROKE_TO_PATH}" != "1" ]; then
  echo "Converting icons to paths"
  CMD="/usr/bin/parallel --bar /usr/bin/inkscape {} \
    --actions="\""select-all;object-to-path;export-overwrite;export-do"\"" ::: ${TEMP_FOLDER}/*.svg"
  AUTHFILE=$(mktemp -p /tmp Xauthority.XXXXXX)
  XAUTHORITY=$AUTHFILE /usr/bin/Xvfb :2020 -screen 0 640x480x24 -nolisten tcp >> /dev/null 2>&1 &
  XVFBPID=$! && DISPLAY=:2020 ${CMD} && kill ${XVFBPID}
fi

echo "Generating font"
/usr/bin/fontcustom compile "${TEMP_FOLDER}"\
  --font-name="${FONT_NAME}"\
  --output=./build\
  --quiet\
  --force\
  --no-hash

if [[ ! -z "${UID}" && ! -z "${GID}" ]]; then
  chown ${UID}:${GID} -R ./build
elif [[ ! -z "${UID}" ]]; then
  chown ${UID}:${UID} -R ./build
fi
rm -rf "${TEMP_FOLDER}"
