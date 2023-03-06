#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Signer::AWSv4::S3;

my $signer = Signer::AWSv4::S3->new(
  time => Time::Piece->strptime('20130524T000000Z', '%Y%m%dT%H%M%SZ'),
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  session_token => 'fooSessionToken9876543210',
  method => 'GET',
  key => 'test.txt',
  bucket => 'examplebucket',
  region => 'us-east-1',
  expires => 86400,
);

my $expected_canon_request = 'GET
/examplebucket/test.txt
X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Security-Token=fooSessionToken9876543210&X-Amz-SignedHeaders=host
host:s3.amazonaws.com

host
UNSIGNED-PAYLOAD';

cmp_ok($signer->canonical_request, 'eq', $expected_canon_request);

my $expected_string_to_sign = 'AWS4-HMAC-SHA256
20130524T000000Z
20130524/us-east-1/s3/aws4_request
1ce3217367127240f226c8c5cb89e6e2b2cbeff9a6a6bf78cbd50fb3b07eff95';

cmp_ok($signer->string_to_sign, 'eq', $expected_string_to_sign);

my $signature = 'baa9ba4567835bc469f3410235f3116036b8685c7460ead98e150e128cca84fa';
cmp_ok($signer->signature, 'eq', $signature);

my $expected_signed_qstring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Security-Token=fooSessionToken9876543210&X-Amz-SignedHeaders=host&X-Amz-Signature=baa9ba4567835bc469f3410235f3116036b8685c7460ead98e150e128cca84fa';
cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);

$signer = Signer::AWSv4::S3->new(
  time => Time::Piece->strptime('20130524T000000Z', '%Y%m%dT%H%M%SZ'),
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  session_token => 'fooSessionToken9876543210',
  method => 'GET',
  key => 'test.txt',
  bucket => 'examplebucket',
  region => 'us-east-1',
  expires => 86400,
  version_id => '1234561zOnAAAJKHxVKBxxEyuy_78901j',
);

$expected_signed_qstring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Security-Token=fooSessionToken9876543210&X-Amz-SignedHeaders=host&versionId=1234561zOnAAAJKHxVKBxxEyuy_78901j&X-Amz-Signature=e3677f60bb4aef0a1a75d95dcde50846ff4849e26764a602022638a18ce69a3d';
cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);

$signer = Signer::AWSv4::S3->new(
  time => Time::Piece->strptime('20130524T000000Z', '%Y%m%dT%H%M%SZ'),
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  session_token => 'fooSessionToken9876543210',
  method => 'GET',
  key => 'test.txt',
  bucket => 'examplebucket',
  region => 'us-east-1',
  expires => 86400,
  version_id => '1234561zOnAAAJKHxVKBxxEyuy_78901j',
  content_type => 'text/plain',
  content_disposition => 'inline; filename=New Name.txt',
);

$expected_signed_qstring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Security-Token=fooSessionToken9876543210&X-Amz-SignedHeaders=host&response-content-disposition=inline%3B%20filename%3DNew%20Name.txt&response-content-type=text%2Fplain&versionId=1234561zOnAAAJKHxVKBxxEyuy_78901j&X-Amz-Signature=5ee5497a04f74c558fbb431876251834d67ed4807d17bd4b11a8418150baed7b';
cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);

done_testing;
