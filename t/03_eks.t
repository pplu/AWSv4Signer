#!/usr/bin/env perl

use Test::More;
use AWSv4::EKS;

# Got this from heptio-authenticator-aws token --cluster-id scrumptious-wardrobe-1531912697 | cut -d '_' -f2 | base64 --decode
# We use the AK, SK, cluster id and timestamp that heptio-authenticator-aws used.
# Note: the timestamp is in the X-Amz-Date above

my $signer = AWSv4::EKS->new(
  time => Time::Piece->strptime('20180723T145707Z', '%Y%m%dT%H%M%SZ'),
  cluster_id => 'scrumptious-wardrobe-1531912697',
  access_key => 'AKIAKIAKIAKIAKIAKIAK',
  secret_key => '1111111111111111111111111111111111111111',
);

diag ($signer->canonical_request);

my $signature = '7a9107b9da0017ba3c84c6331d1aed6afe1de75da6c39ea786c01c31141052a8';
cmp_ok($signer->signature, 'eq', $signature);

my $expected_signed_qstring = 'Action=GetCallerIdentity&Version=2011-06-15&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAKIAKIAKIAKIAKIAK%2F20180723%2Fus-east-1%2Fsts%2Faws4_request&X-Amz-Date=20180723T145707Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host%3Bx-k8s-aws-id&X-Amz-Signature=7a9107b9da0017ba3c84c6331d1aed6afe1de75da6c39ea786c01c31141052a8';

cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);


