#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Signer::AWSv4::SES;

my $signer = Signer::AWSv4::SES->new(
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
);

cmp_ok($signer->smtp_user, 'eq', 'AKIAIOSFODNN7EXAMPLE');
cmp_ok($signer->smtp_password, 'eq', 'An60U4ZD3sd4fg+FvXUjayOipTt8LO4rUUmhpdX6ctDy');

done_testing;
