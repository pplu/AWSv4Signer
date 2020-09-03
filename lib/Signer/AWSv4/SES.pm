package Signer::AWSv4::SES;
  use Moo;
  use Types::Standard qw/Str Int/;
  use Digest::SHA qw//;
  use MIME::Base64 qw//;

  has access_key => (is => 'ro', isa => Str, required => 1);
  has secret_key => (is => 'ro', isa => Str, required => 1);

  has smtp_user => (is => 'ro', isa => Str, default => sub {
    my $self = shift;
    return $self->access_key;    
  });
  has smtp_password => (is => 'ro', isa => Str, builder => '_build_password');

  sub _build_password {
    my $self = shift;

    my $message = 'SendRawEmail';
    my $version = "\x02";
    my $signature = Digest::SHA::hmac_sha256($message, $self->secret_key);
    MIME::Base64::encode_base64url($version . $signature);
  }

1;
### main pod documentation begin ###

=encoding UTF-8

=head1 NAME

Signer::AWSv4::SES - Generate passwords for sending email through SES SMTP servers with IAM credentials

=head1 SYNOPSIS

  use Signer::AWSv4::SES;
  $pass_gen = Signer::AWSv4::SES->new(
    access_key => 'AKIAIOSFODNN7EXAMPLE',
    secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  );
  $pass_gen->smtp_password;

=head1 DESCRIPTION

Generate passwords for sending email through SES SMTP servers with IAM credentials.
The IAM user needs to have the ses:SendRawEmail IAM permission to be able to send mail.

=head1 Request Attributes

This module needs only two required attributes in the constructor for obtaining a password:

=head2 access_key String

The AWS IAM Access Key for the IAM user

=head2 user String

The user of the MySQL database

=head2 port Integer

The port the database is running on. Defaults to 3306.

=head1 Signature Attributes

=head2 signed_qstring

This has to be used as the password for the MySQL Server. Please note that all of this needs
extra setup: correctly configuring your AWS environment AND your MySQL Client.

=head1 SEE ALSO

L<https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp.html>

=head1 BUGS and SOURCE

The source code is located here: L<https://github.com/pplu/AWSv4Signer>

Please report bugs to: L<https://github.com/pplu/AWSv4Signer/issues>

=head1 AUTHOR

    Jose Luis Martinez
    CAPSiDE
    jlmartinez@capside.com

=head1 COPYRIGHT and LICENSE

Copyright (c) 2018 by CAPSiDE

This code is distributed under the Apache 2 License. The full text of the license can be found in the LICENSE file included with this module.

=cut
