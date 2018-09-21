package Signer::AWSv4::RDS;
  use Moo;
  extends 'Signer::AWSv4';
  use Types::Standard qw/Str Int/;

  has '+expires' => (default => 900);
  has '+service' => (default => 'rds-db');
  has '+method' => (default => 'GET');
  has '+uri' => (default => '/');

  has host => (is => 'ro', isa => Str, required => 1);
  has user => (is => 'ro', isa => Str, required => 1);
  has port => (is => 'ro', isa => Int, default => 3306);

  sub build_params {
    my $self = shift;
    {
      'Action' => 'connect',
      'DBUser' => $self->user,
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
      Host => $self->host . ':' . $self->port,
    }
  }

1;
