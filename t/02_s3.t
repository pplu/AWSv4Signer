#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Signer::AWSv4::S3;

my $signer = Signer::AWSv4::S3->new(
  time => Time::Piece->strptime('20130524T000000Z', '%Y%m%dT%H%M%SZ'),
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  method => 'GET',
  uri => '/test.txt',
  bucket => 'examplebucket',
  region => 'us-east-1',
  expires => 86400,
);

my $expected_canon_request = 'GET
/test.txt
X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host
host:examplebucket.s3.amazonaws.com

host
UNSIGNED-PAYLOAD';

cmp_ok($signer->canonical_request, 'eq', $expected_canon_request);

my $expected_string_to_sign = 'AWS4-HMAC-SHA256
20130524T000000Z
20130524/us-east-1/s3/aws4_request
3bfa292879f6447bbcda7001decf97f4a54dc650c8942174ae0a9121cf58ad04';

cmp_ok($signer->string_to_sign, 'eq', $expected_string_to_sign);

my $signature = 'aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404';
cmp_ok($signer->signature, 'eq', $signature);


my $expected_signed_qstring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404';
cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);

done_testing;
