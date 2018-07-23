package AWSv4::S3;
  use Moose;
  extends 'AWSv4';

  has bucket => (is => 'ro', isa => 'Str');

  has '+service' => (default => 's3');

  has bucket_host => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join '.', $self->bucket, 's3.amazonaws.com';
  });

  has '+dont_sign_payload' => (default => 1);

  use URI::Escape;

  has '+params' => (lazy => 1, default => sub {
    my $self = shift;
    {
      'X-Amz-Algorithm' => $self->aws_algorithm,
      'X-Amz-Credential' => uri_escape($self->access_key . "/" . $self->credential_scope),
      'X-Amz-Date' => $self->date_timestamp,
      'X-Amz-Expires' => $self->expires,
      'X-Amz-SignedHeaders' => uri_escape($self->signed_header_list),
    }
  });

  has '+headers' => (lazy => 1, default => sub {
    my $self = shift;
    {
      Host => $self->bucket_host,
    }
  });

1;
