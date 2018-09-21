package Signer::AWSv4;
  use Moo;
  use Types::Standard qw/Str Int HashRef Bool InstanceOf ArrayRef/;
  use Time::Piece;
  use Digest::SHA qw//;
  use URI::Escape qw//;

  our $VERSION = '0.01';

  has access_key => (is => 'ro', isa => Str, required => 1);
  has secret_key => (is => 'ro', isa => Str, required => 1);
  has method => (is => 'ro', isa => Str, required => 1);
  has uri => (is => 'ro', isa => Str, required => 1);
  has region => (is => 'ro', isa => Str, required => 1);
  has service => (is => 'ro', isa => Str, required => 1);

  has expires => (is => 'ro', isa => Int, required => 1);

  has time => (is => 'ro', isa => InstanceOf['Time::Piece'], default => sub {
    localtime;
  });

  has date => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->time->ymd('');
  });

  has date_timestamp => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->time->ymd('') . 'T' . $self->time->hms('') . 'Z';
  });

  has params  => (is => 'ro', isa => HashRef, lazy => 1, builder => 'build_params');
  has headers => (is => 'ro', isa => HashRef, lazy => 1, builder => 'build_headers');
  has content => (is => 'ro', isa => Str, default => '');
  has unsigned_payload => (is => 'ro', isa => Bool, default => 0);

  has canonical_qstring => (is => 'ro', isa => Str, lazy => 1, default => sub {
    my $self = shift;
    join '&', map { $_ . '=' . URI::Escape::uri_escape($self->params->{ $_ }) } sort keys %{ $self->params };
  });

  has header_list => (is => 'ro', isa => ArrayRef, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    [ sort keys %{ $self->headers } ];
  });

  has canonical_headers => (is => 'ro', isa => Str, lazy => 1, default => sub {
    my $self = shift;
    join '', map { lc( $_ ) . ":" . $self->headers->{ $_ } . "\n" } @{ $self->header_list };
  });

  has hashed_payload => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    return ($self->unsigned_payload) ? 'UNSIGNED-PAYLOAD' : Digest::SHA::sha256_hex($self->content);
  });

  has signed_header_list => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join ';', map { lc($_) } @{ $self->header_list };
  });

  has canonical_request => (is => 'ro', isa => Str, lazy => 1, default => sub {
    my $self = shift;
    join "\n", $self->method,
               $self->uri,
               $self->canonical_qstring,
               $self->canonical_headers,
               $self->signed_header_list,
               $self->hashed_payload;
  });

  has credential_scope => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join '/', $self->date, $self->region, $self->service, 'aws4_request';
  });

  has aws_algorithm => (is => 'ro', isa => Str, init_arg => undef, default => 'AWS4-HMAC-SHA256');

  has string_to_sign => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join "\n", $self->aws_algorithm,
               $self->date_timestamp,
               $self->credential_scope,
               Digest::SHA::sha256_hex($self->canonical_request);
  });

  has signing_key => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    my $kSecret = "AWS4" . $self->secret_key;
    my $kDate = Digest::SHA::hmac_sha256($self->date, $kSecret);
    my $kRegion = Digest::SHA::hmac_sha256($self->region, $kDate);
    my $kService = Digest::SHA::hmac_sha256($self->service, $kRegion);
    return Digest::SHA::hmac_sha256("aws4_request", $kService);
  });

  has signature => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    Digest::SHA::hmac_sha256_hex($self->string_to_sign, $self->signing_key);
  });

  has signed_qstring => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->canonical_qstring . '&X-Amz-Signature=' . $self->signature;
  });

1;
### main pod documentation begin ###

=encoding UTF-8

=head1 NAME

Signer::AWSv4 - Implements the AWS v4 signature algorithm

=head1 DESCRIPTION

Yet Another module to sign requests to Amazon Web Services APIs 
with the AWSv4 signing algorithm. This module has a different twist. The
rest of modules out there tied to signing HTTP::Request objects, but 
AWS uses v4 signatures in other places: IAM user login to MySQL RDSs, EKS, 
S3 Presigned URLs, etc. When building authentication modules for these services, 
I've had to create artificial HTTP::Request objects, just for a signing module
to sign them, and then retrieve the signature. This module solves that problem,
not being tied to any specific object to sign.

Signer::AWSv4 is a base class that implements the main v4 Algorithm. You're supposed
L<https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html>
to subclass and override attributes to adjust how you want the signature to
be built.

=head1 Specialized Signers

L<Signer::AWSv4::S3> - Build presigned URLs

L<Signer::AWSv4::EKS> - Login to EKS clusters

L<Signer::AWSv4::RDS> - Login to MySQL RDS servers with IAM credentials

=head1 AUTHOR

    Jose Luis Martinez
    CPAN ID: JLMARTIN
    CAPSiDE
    jlmartinez@capside.com

=head1 SEE ALSO

L<AWS::Signature4>

L<Net::Amazon::Signature::V4>

L<WebService::Amazon::Signature::v4>

=head1 BUGS and SOURCE

The source code is located here: L<https://github.com/pplu/AWSv4Signer>

Please report bugs to: L<https://github.com/pplu/AWSv4Signer/issues>

=head1 COPYRIGHT and LICENSE

Copyright (c) 2018 by Jose Luis Martinez Torres

This code is distributed under the Apache 2 License. The full text of the license can be found in the LICENSE file included with this module.

=cut
