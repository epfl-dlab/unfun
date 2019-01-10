#!/usr/local/bin/perl

# This script augments the training data for the OpenNLP chunker model to mimic
# pithy, headline-style text. For instance, we remove articles, copulas, and transform
# definitive verbs to gerunds. The original data is kept as well; it is merely
# augmented by adding modified versions for each sentence.

# The resulting corpus will be used to train an OpenNLP maxent chunker model,
# cf. ../bash/retrain_chunking_model.sh.

# $BASE_DIR refers to the directory that is created when unzipping the archive
# available at https://archive.apache.org/dist/opennlp/opennlp-1.9.0/.
$BASE_DIR = "../apache-opennlp-1.9.0";

my $DATA_DIR = "$BASE_DIR/data";
my $MODEL_DIR = "$BASE_DIR/models";

my %token_to_lemma = ();
my %lemma_to_gerund = ();
open(LEMMA, "$MODEL_DIR/en-lemmatizer.dict") or die $!;
while (my $line = <LEMMA>) {
  chomp $line;
  my ($token, $pos, $lemma) = split /\t/, $line;
  if ($pos =~ /^(VBD|VBP|VBZ)$/ && $lemma !~ /^(do|have)$/) {
    $token_to_lemma{$token} = $lemma;
  } elsif ($pos eq 'VBG') {
    $lemma_to_gerund{$lemma} = $token;
  }
}
close(LEMMA);

my %token_to_gerund = ();
foreach my $token (keys %token_to_lemma) {
  my $lemma = $token_to_lemma{$token};
  if (defined $lemma_to_gerund{$lemma}) {
    $token_to_gerund{$token} = $lemma_to_gerund{$lemma};
  }
}

my $PREV_TOKENS_PREVENTING_MODIFICATION = '^(who|which|there|this|that|he|she|it|they|we|you)$';

open(POS, ">", "$DATA_DIR/en-pos_AUGMENTED_LOWERCASE_HEADLINESTYLE.train");
open(CHUNK, ">", "$DATA_DIR/en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.train");

for ($phase = 1; $phase <= 3; ++$phase) {
  my $prev_line_deleted = 0;
  my $prev_token = '';
  my $prev_BI = '';
  my $sep = '';
  open(IN, "$DATA_DIR/en-chunker.train") or die $!;
  while (my $line = <IN>) {
    if ($line eq "\n") {
      print CHUNK "\n";
      print POS "\n";
      $prev_line_deleted = 0;
      $prev_token = '';
      $prev_BI = '';
      $sep = '';
    } else {
      chomp $line;
      my @tokens = split(/ /, $line);
      $tokens[0] = lc($tokens[0]);
      my $BI = substr($tokens[2], 0, 1);
      my $print = 0;
      ### PHASE 1: make all tokens lower-case.
      if ($phase == 1) {
        $print = 1;
      }
      ### PHASES 2 AND 3.
      else {
        if ($tokens[0] =~ /^(the|a)$/) {
          # Don't print articles.
        } elsif ($tokens[0] =~ /^(is|are|was|were)$/) {
          # Print forms of "to be" only if not proceeded by a pronoun.
          if ($prev_token =~ /$PREV_TOKENS_PREVENTING_MODIFICATION/) {
            $print = 1;
          }
        } else {
          ### PHASE 2: make sentences more headline-like by removing "the", "a", "is", "are", "was", "were".
          if ($phase == 2) {
            $print = 1;
          }
          ### PHASE 3: additionally transform definite verbs to gerunds.
          elsif ($phase == 3) {
            if ($tokens[1] =~ /^(VBD|VBP|VBZ)$/ && defined $token_to_gerund{$tokens[0]} && $prev_token !~ /$PREV_TOKENS_PREVENTING_MODIFICATION/) {
              $tokens[0] = $token_to_gerund{$tokens[0]};
              $tokens[1] = 'VBG';
            }
            $print = 1;
          }
        }
        # If we deleted a word, we need to fix the 'B' and 'I' tags.
        if ($prev_line_deleted && $prev_BI eq 'B' && $BI eq 'I') {
          $tokens[2] =~ s/^I-/B-/;
        }
      }
      ### ALL PHASES: Print the output.
      if ($print) {
        print CHUNK join(' ', @tokens) . "\n";
        print POS "$sep$tokens[0]_$tokens[1]";
        $prev_line_deleted = 0;
        $sep = ' ';
      } else {
        $prev_line_deleted = 1;
      }
      $prev_token = $tokens[0];
      $prev_BI = $BI;
    }
  }
  close(IN);
}

close(POS);
close(CHUNK);
