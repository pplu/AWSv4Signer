#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use HTTP::Request;
use Path::Tiny;
use Signer::AWSv4::HTTPRequest;

foreach my $test (glob('t/aws-sig-v4-test-suite/*')) {
  my ($test_name) = ($test =~ m|t/aws-sig-v4-test-suite\/(.*?)$|);

  my $request_file = "$test/$test_name.req";
  next if (not -s $request_file);
  note $test;

  my $r = HTTP::Request->parse(path($request_file)->slurp_utf8);
  use Data::Dumper;
  print Dumper($r);

  my $signer = Signer::AWSv4::HTTPRequest->new(
    request => $r,
    access_key => 'AKIDEXAMPLE',
    secret_key => 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
    service => 'service',
    region => 'us-east-1',
  );

  my $sts_content = path("$test/$test_name.sts")->slurp_raw;
  cmp_ok($signer->string_to_sign, 'eq', $sts_content);

  my $creq_content = path("$test/$test_name.creq")->slurp_raw;
  cmp_ok($signer->canonical_request, 'eq', $creq_content);

}

done_testing;
