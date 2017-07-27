#!/bin/bash -x

if [ "$1" == "build_voice" ] && [ "$#" -eq 4 ]; then
  echo "Start building a voice on Docker..."
  WAV_TAR=$2
  LANGUAGE=$3
  VOICE_TAR=$4

  WAV_DIR=/mnt/data/wav
  VOICE_DIR=/mnt/data/built_voice

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  mkdir -p ${WAV_DIR} && tar xzvf ${WAV_TAR} -C ${WAV_DIR}

  # Temporary operation to filter in only lines that we have .wav files.
  echo "Filter in only lines that we have .wav files..."
  for i in $(ls ${WAV_DIR}) ; do
    grep "$(echo $i | sed 's/.wav//g')" si/festvox/txt.done.data >> /mnt/data/text
  done
  cp /mnt/data/text si/festvox/txt.done.data
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

  # Only for the 1st time, we untar to extract the compressed model.
  if [ ! -d "${EXTRACTED_VOICE}" ]; then
    mkdir -p ${EXTRACTED_VOICE} && tar xzvf ${INPUT_MODEL} -C ${EXTRACTED_VOICE}
  fi

  cd ${EXTRACTED_VOICE}
  echo ${INPUT_TEXT} | ${FESTIVALDIR}/bin/text2wave \
    -eval festvox/goog_${LANGUAGE}_unison_cg.scm \
    -eval "(voice_goog_${LANGUAGE}_unison_cg)" \
    > ${OUTPUT_WAV}
elif [ "$1" == "build_generic_voice" ] && [ "$#" -eq 7 ]; then
  echo "Build generic voice on Docker..."
  LANGUAGE=$2
  WAV_TAR=$3
  PHONOLOGY_JSON=$4
  LEXICON_SCM=$5
  TEXT_LINE=$6
  VOICE_TAR=$7

  WAV_DIR=/mnt/data/wav
  VOICE_DIR=/mnt/data/built_voice

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  mkdir -p ${WAV_DIR} && tar xzvf ${WAV_TAR} -C ${WAV_DIR}

  # Create langauge folder in festvox and move all necessary files to build voice.
  # TODO: Add ENV VAR for langauge-resources in Dockerfile
  FESTVOX_LANG_FOLDER=/usr/local/src/language-resources/${LANGUAGE}/festvox
  mkdir -p ${FESTVOX_LANG_FOLDER}
  cp ${PHONOLOGY_JSON} ${FESTVOX_LANG_FOLDER}/ipa_phonology.json
  cp ${LEXICON_SCM} ${FESTVOX_LANG_FOLDER}/lexicon.scm
  cp ${TEXT_LINE} ${FESTVOX_LANG_FOLDER}/txt.done.data
  # end

  # Temporary operation to filter in only lines that we have .wav files.
  echo "Filter in only lines that we have .wav files..."
  for i in $(ls ${WAV_DIR}) ; do
    grep "$(echo $i | sed 's/.wav//g')" ${LANGUAGE}/festvox/txt.done.data >> /mnt/data/text
  done
  cp /mnt/data/text ${LANGUAGE}/festvox/txt.done.data
  # end

  echo "Add -x to better debugging on all scripts..."
  sed -i '1s/bash/bash -x/g' ./utils/build_festvox_voice.sh
  sed -i '69i sed -i "1s/sh/sh -x/g" ${VOICE_DIR}/bin/*' ./utils/build_festvox_voice.sh
  ./utils/build_festvox_voice.sh ${WAV_DIR} ${LANGUAGE} ${VOICE_DIR}

  cd ${VOICE_DIR} && tar czvf ${VOICE_TAR} .
elif [ "$1" == "build_generic_optimized_voice" ] && [ "$#" -eq 7 ]; then
  echo "Build generic voice on Docker..."
  LANGUAGE=$2
  WAV_TAR=$3
  PHONOLOGY_JSON=$4
  LEXICON_SCM=$5
  TEXT_LINE=$6
  VOICE_TAR=$7

  WAV_DIR=/mnt/data/wav
  VOICE_DIR=/mnt/data/built_voice

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  mkdir -p ${WAV_DIR} && tar xzvf ${WAV_TAR} -C ${WAV_DIR}

  # Create langauge folder in festvox and move all necessary files to build voice.
  # TODO: Add ENV VAR for langauge-resources in Dockerfile
  FESTVOX_LANG_FOLDER=/usr/local/src/language-resources/${LANGUAGE}/festvox
  mkdir -p ${FESTVOX_LANG_FOLDER}
  cp ${PHONOLOGY_JSON} ${FESTVOX_LANG_FOLDER}/ipa_phonology.json
  cp ${LEXICON_SCM} ${FESTVOX_LANG_FOLDER}/lexicon.scm
  cp ${TEXT_LINE} ${FESTVOX_LANG_FOLDER}/txt.done.data
  # end

  # Temporary operation to filter in only lines that we have .wav files.
  echo "Filter in only lines that we have .wav files..."
  for i in $(ls ${WAV_DIR}) ; do
    grep "$(echo $i | sed 's/.wav//g')" ${LANGUAGE}/festvox/txt.done.data >> /mnt/data/text
  done
  cp /mnt/data/text ${LANGUAGE}/festvox/txt.done.data
  # end

  echo "Add -x to better debugging on all scripts..."
  sed -i '1s/bash/bash -x/g' ./utils/build_festvox_voice.sh
  sed -i '69i sed -i "1s/sh/sh -x/g" ${VOICE_DIR}/bin/*' ./utils/build_festvox_voice.sh
  ./utils/build_festvox_voice.sh ${WAV_DIR} ${LANGUAGE} ${VOICE_DIR}

  cd ${VOICE_DIR} && time bin/build_cg_rfs_voice

  cd ${VOICE_DIR} && tar czvf ${VOICE_TAR} .
elif [ "$1" == "build_only_feature_from_ehmm" ] && [ "$#" -eq 7 ]; then
  echo "Build only feature from do_ehmm script..."
  LANGUAGE=$2
  WAV_TAR=$3
  PHONOLOGY_JSON=$4
  LEXICON_SCM=$5
  TEXT_LINE=$6
  VOICE_TAR=$7

  WAV_DIR=/mnt/data/wav
  VOICE_DIR=/mnt/data/built_voice

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  mkdir -p ${WAV_DIR} && tar xzvf ${WAV_TAR} -C ${WAV_DIR}

  # Create langauge folder in festvox and move all necessary files to build voice.
  # TODO: Add ENV VAR for langauge-resources in Dockerfile
  FESTVOX_LANG_FOLDER=/usr/local/src/language-resources/${LANGUAGE}/festvox
  mkdir -p ${FESTVOX_LANG_FOLDER}
  cp ${PHONOLOGY_JSON} ${FESTVOX_LANG_FOLDER}/ipa_phonology.json
  cp ${LEXICON_SCM} ${FESTVOX_LANG_FOLDER}/lexicon.scm
  cp ${TEXT_LINE} ${FESTVOX_LANG_FOLDER}/txt.done.data
  # end

  # Temporary operation to filter in only lines that we have .wav files.
  echo "Filter in only lines that we have .wav files..."
  for i in $(ls ${WAV_DIR}) ; do
    grep "$(echo $i | sed 's/.wav//g')" ${LANGUAGE}/festvox/txt.done.data >> /mnt/data/text
  done
  cp /mnt/data/text ${LANGUAGE}/festvox/txt.done.data
  # end

  echo "Add -x to better debugging on all scripts..."
  sed -i '1s/bash/bash -x/g' ./utils/build_festvox_voice.sh
  sed -i '69i sed -i "1s/sh/sh -x/g" ${VOICE_DIR}/bin/*' ./utils/build_festvox_voice.sh

  cp /build_cg_voice_only_feature_extraction ${VOICE_DIR}/bin/build_cg_voice

  ./utils/build_festvox_voice.sh ${WAV_DIR} ${LANGUAGE} ${VOICE_DIR}

  cd ${VOICE_DIR} && tar czvf ${VOICE_TAR} .

elif [ "$1" == "build_generic_voice_with_features" ] && [ "$#" -eq 7 ]; then
  echo "Build generic voice on Docker..."
  LANGUAGE=$2
  WAV_TAR=$3
  PHONOLOGY_JSON=$4
  LEXICON_SCM=$5
  TEXT_LINE=$6
  VOICE_TAR=$7

  WAV_DIR=/mnt/data/wav
  VOICE_DIR=/mnt/data/built_voice

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

  mkdir -p ${WAV_DIR} && tar xzvf ${WAV_TAR} -C ${WAV_DIR}

  # Create langauge folder in festvox and move all necessary files to build voice.
  # TODO: Add ENV VAR for langauge-resources in Dockerfile
  FESTVOX_LANG_FOLDER=/usr/local/src/language-resources/${LANGUAGE}/festvox
  mkdir -p ${FESTVOX_LANG_FOLDER}
  cp ${PHONOLOGY_JSON} ${FESTVOX_LANG_FOLDER}/ipa_phonology.json
  cp ${LEXICON_SCM} ${FESTVOX_LANG_FOLDER}/lexicon.scm
  cp ${TEXT_LINE} ${FESTVOX_LANG_FOLDER}/txt.done.data
  # end

  # Temporary operation to filter in only lines that we have .wav files.
  echo "Filter in only lines that we have .wav files..."
  for i in $(ls ${WAV_DIR}) ; do
    grep "$(echo $i | sed 's/.wav//g')" ${LANGUAGE}/festvox/txt.done.data >> /mnt/data/text
  done
  cp /mnt/data/text ${LANGUAGE}/festvox/txt.done.data
  # end

  echo "Add -x to better debugging on all scripts..."
  sed -i '1s/bash/bash -x/g' ./utils/build_festvox_voice.sh
  sed -i '69i sed -i "1s/sh/sh -x/g" ${VOICE_DIR}/bin/*' ./utils/build_festvox_voice.sh
  ./utils/build_festvox_voice.sh ${WAV_DIR} ${LANGUAGE} ${VOICE_DIR}

  cd ${VOICE_DIR} && tar czvf ${VOICE_TAR} .
fi
