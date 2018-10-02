#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use HTTP::Request;
use Path::Tiny;

foreach my $test (glob('t/aws-sig-v4-test-suite/*')) {
  my ($test_name) = ($test =~ m|t/aws-sig-v4-test-suite\/(.*?)$|);

  my $request_file = "$test/$test_name.req";
  next if (not -s $request_file);
  note $test;

  my $r = HTTP::Request->parse(path($request_file)->slurp_utf8);

  use Data::Dumper;
  print Dumper($r);
}

done_testing;
