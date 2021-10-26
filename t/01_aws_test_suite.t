#!/usr/bin/env perl

#
# Before running this test suite, you should `make build-test-suite` to get the official AWS v4 Signature test
# suite into place in the directory structure
#

use strict;
use warnings;
use Test::More;
use HTTP::Request;
use Path::Tiny;
use Signer::AWSv4::HTTPRequest;

foreach my $test (glob('t/aws-sig-v4-test-suite/aws-sig-v4-test-suite/aws-sig-v4-test-suite/*')) {
  my ($test_name) = ($test =~ m|t\/aws-sig-v4-test-suite\/aws-sig-v4-test-suite\/aws-sig-v4-test-suite\/(.*?)$|);

use Data::Dumper;
print Dumper("$test/$test_name.req");

  my $request_file = "$test/$test_name.req";
  next if (not -s $request_file);
  note $test;

  my $r = HTTP::Request->parse(path($request_file)->slurp_utf8);
  use Data::Dumper;
  print Dumper($r);

  my $signer = Signer::AWSv4::HTTPRequest->new(
    request => $r,
    time => Time::Piece->strptime('20150830T123600Z', '%Y%m%dT%H%M%SZ'),
    access_key => 'AKIDEXAMPLE',
    secret_key => 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
    service => 'service',
    region => 'us-east-1',
  );

  my $sts_content = path("$test/$test_name.sts")->slurp_raw;
  cmp_ok($signer->string_to_sign, 'eq', $sts_content, "String to sign $test/$test_name.sts");

  my $creq_content = path("$test/$test_name.creq")->slurp_raw;
  cmp_ok($signer->canonical_request, 'eq', $creq_content, "Canonical request $test/$test_name.creq");

}

done_testing;
