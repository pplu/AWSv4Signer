package AWSv4::RDS;
  use Moose;
  extends 'AWSv4';

  use URI::Escape;

  has '+expires' => (default => 900);
  has '+service' => (default => 'rds-db');
  has '+method' => (default => 'GET');
  has '+uri' => (default => '/');

  has host => (is => 'ro', isa => 'Str', required => 1);
  has user => (is => 'ro', isa => 'Str', required => 1);
  has port => (is => 'ro', isa => 'Int', default => 3306);

  has '+params' => (lazy => 1, default => sub {
    my $self = shift;
    {
      'Action' => 'connect',
      'DBUser' => $self->user,
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
      Host => $self->host . ':' . $self->port,
    }
  });

1;
