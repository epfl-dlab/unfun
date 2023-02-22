#!/usr/local/bin/perl

# Note: This script is to be run on the original, raw database dump, which is not made available on GitHub.
# (Only the result of this script is made available on GitHub.)
# This script is provided merely for transparency purposes.

use Digest::SHA qw(sha256_hex);

my $DATA_DIR = $ENV{'HOME'} . "/github/unfun/data/";
my $SALT = `cat salt.txt`;
chomp $SALT;

open(DB, "gunzip -c $DATA_DIR/unfun.sql.gz |");

my $mute = 0;
my $table = '';

while (my $line = <DB>) {
  if ($line =~ /^-- (Table structure|Indexes) for table `(.*)`/) {
    $table = $2;
    $mute = ($table eq 'most_recent_events' || $table eq 'next_guest_id' || $table eq 'users');
  }
  if (!$mute) {
    if ($table eq 'batches') {
      if ($line =~ /\('(.+)', '(.+)', '(.+)', '(.+)', '(.+)'\)([,;]?)/) {
        my ($id, $uid, $date, $http_user_agent, $ip_address, $sep) = ($1, $2, $3, $4, $5, $6);
        $http_user_agent = sha256_hex($http_user_agent . $SALT);
        $ip_address = sha256_hex($ip_address . $SALT);
        $line = "('$id', '$uid', '$date', '$http_user_agent', '$ip_address')$sep\n";
      }
    }
    print $line;
  }
}

close(DB);

