package AWSv4::S3;
  use Moose;
  extends 'AWSv4';

  has bucket => (is => 'ro', isa => 'Str');

  has '+service' => (default => 's3');

  has bucket_host => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join '.', $self->bucket, 's3.amazonaws.com';
  });

  has '+unsigned_payload' => (default => 1);

  sub build_params {
    my $self = shift;
    {
      'X-Amz-Algorithm' => $self->aws_algorithm,
      'X-Amz-Credential' => $self->access_key . "/" . $self->credential_scope,
      'X-Amz-Date' => $self->date_timestamp,
      'X-Amz-Expires' => $self->expires,
      'X-Amz-SignedHeaders' => $self->signed_header_list,
    }
  }

  sub build_headers {
    my $self = shift;
    {
      Host => $self->bucket_host,
    }
  }

1;
