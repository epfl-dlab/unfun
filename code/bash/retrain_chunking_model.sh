#!/bin/bash

# Retrain the OpenNLP chunker model to be able to deal with pithy, headline-style text.
# The training data is produced by ../perl/augment_conll_training_data.pl.

# The model that will result from this script is also available in the file
# ../../data/en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.bin,
# so if you don't want to train the model yourself using this script, just copy the
# ready-made model file to $MODEL_DIR.

# OPENNLP_DIR refers to the directory that is created when unzipping the archive
# available at https://archive.apache.org/dist/opennlp/opennlp-1.9.0/.
OPENNLP_DIR=../apache-opennlp-1.9.0

OPENNLP=$OPENNLP_DIR/bin/opennlp
DATA_DIR=$OPENNLP_DIR/data
MODEL_DIR=$OPENNLP_DIR/models

echo 'Iterations=500' > /tmp/chunker_training_params.txt \
&& $OPENNLP ChunkerTrainerME \
-params /tmp/chunker_training_params.txt \
-model $MODEL_DIR/en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.bin \
-lang en \
-data $DATA_DIR/en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.train \
-encoding UTF-8
