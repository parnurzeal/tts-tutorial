#!/bin/bash -x

if [ "$1" == "build_voice" ] && [ "$#" -eq 4 ]; then
  echo "Start building a voice on Docker..."
  WAV_TAR=$2
  LANGUAGE=$3
  VOICE_TAR=$4

  WAV_DIR=/tmp/wav
  VOICE_DIR=/tmp/built_voice

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  mkdir -p ${WAV_DIR} && tar xzvf ${WAV_TAR} -C ${WAV_DIR}

  # Temporary operation to filter in only lines that we have .wav files.
  echo "Filter in only lines that we have .wav files..."
  for i in $(ls ${WAV_DIR}) ; do
    grep "$(echo $i | sed 's/.wav//g')" si/festvox/txt.done.data >> /tmp/text
  done
  cp /tmp/text si/festvox/txt.done.data
  # end

  echo "Add -x to better debugging on all scripts..."
  sed -i '1s/bash/bash -x/g' ./utils/build_festvox_voice.sh
  sed -i '69i sed -i "1s/sh/sh -x/g" ${VOICE_DIR}/bin/*' ./utils/build_festvox_voice.sh
  ./utils/build_festvox_voice.sh ${WAV_DIR} ${LANGUAGE} ${VOICE_DIR}

  cd ${VOICE_DIR} && tar czvf ${VOICE_TAR} .
elif [ "$1" == "run_voice" ] && [ "$#" -eq 5 ]; then
  echo "Produce a wav from target voice model on Docker..."
  INPUT_MODEL=$2
  LANGUAGE=$3
  INPUT_TEXT=$4
  OUTPUT_WAV=$5

  EXTRACTED_VOICE=/tmp/voice/

  mkdir -p ${EXTRACTED_VOICE} && tar xzvf ${INPUT_MODEL} -C ${EXTRACTED_VOICE}

  cd ${EXTRACTED_VOICE}
  echo ${INPUT_TEXT} | ${FESTIVALDIR}/bin/text2wave \
    -eval festvox/goog_${LANGUAGE}_unison_cg.scm \
    -eval "(voice_goog_${LANGUAGE}_unison_cg)" \
    > ${OUTPUT_WAV}
fi
