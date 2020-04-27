#!/usr/local/bin/perl

# Chunking (a.k.a. shallow parsing) of headlines. We use the OpenNLP maxent chunking model,
# as trained in ../bash/retrain_chunking_model.sh.

if ($#ARGV < 0) {
  die "You must specify the source (THEONION or UNFUNNED)";
} else {
  $SOURCE = $ARGV[0];
  if ($SOURCE ne 'THEONION' and $SOURCE ne 'UNFUNNED') {
    die "Source must be either THEONION or UNFUNNED";
  }
}

# $OPENNLP_DIR refers to the directory that is created when unzipping the archive
# available at https://archive.apache.org/dist/opennlp/opennlp-1.9.0/.
my $OPENNLP_DIR = "../apache-opennlp-1.9.0";
my $MODEL_DIR = "$OPENNLP_DIR/models";
my $OPENNLP = "$OPENNLP_DIR/bin/opennlp";

my $DATA_DIR = "../../data";
my $TOK_CMD = "$OPENNLP TokenizerME $MODEL_DIR/en-token.bin";
my $POS_CMD = "$OPENNLP POSTagger $MODEL_DIR/en-pos-maxent.bin";
# The augmented chunker model is available in the file
# ../../data/en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.bin,
# which you should copy to $MODEL_DIR. Alternatively, you can create the augmented model yourself
# by running ../bash/retrain_chunking_model.sh before running this script.
my $CHUNK_CMD = "$OPENNLP ChunkerME $MODEL_DIR/en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.bin";

sub reformat {
  my $seq = shift;
  my $orig = shift;
  chomp $orig;

  # Remove starting whitespace.
  if ($seq =~ m{ (.*)}) { $seq = $1; }
  # Remove trailing whitespace within chunks.
  $seq =~ s/ \]/\]/g;
  # Remove the period that we artificially added.
  $seq =~ s/ \._\.$//g; 

  my $PLACEHOLDER = '@@@';

  # Replace whitespace within chunks by $PLACEHOLDER, so we can thereafter split chunks by
  # splitting on whitespace.
  $seq_old = $seq;
  while ($seq_old =~ /\[(.*?)\]/g) {
    my $match = $1;
    my $escaped = $match;
    $escaped =~ s/ /$PLACEHOLDER/g;
    $seq =~ s/\Q$match\E/$escaped/;
  }

  my @tag_array = ();
  my @chunk_array = ();

  foreach my $chunk (split / /, $seq) {
    $chunk =~ s/$PLACEHOLDER/ /g;
    my $starts_with_bracket = (substr($chunk, 0, 1) eq '[');
    if ($starts_with_bracket) {
      if ($chunk =~ /^\[([A-Z]+) /) {
        $tag = $1;
      }
      $chunk_clean = $chunk;
      $chunk_clean =~ s/([^\[ ]*?)_.*?([ \]])/$1$2/g;
    } else {
      $chunk =~ s/(.*?)_.*/$1/g;
      $tag = $chunk;
      $chunk_clean = $chunk;
    }
    push(@tag_array, $tag);
    push(@chunk_array, $chunk_clean);
  }

  return $orig . "\t" . join(' ', @chunk_array) . "\t" . join(' ', @tag_array) . "\n";
}

my $cmd = ($SOURCE eq 'THEONION' ? "cut -f1 $DATA_DIR/headlines_for_game.tsv" : "cut -f5 $DATA_DIR/pairs_with_ratings.csv");
my @orig_headlines = split(/\n/, `$cmd`);
# NB: Adding a period at the end of sentences seems to improve tag quality for the last word.
my @chunked_headlines = split(/\n/, `$cmd | sed 's/\\(.*\\)/\\1./' | tr A-Z a-z | $TOK_CMD | $POS_CMD | $CHUNK_CMD`);

for ($n = 0; $n <= $#chunked_headlines; ++$n) {
  print reformat($chunked_headlines[$n], $orig_headlines[$n]);
}

