package AWSv4::EKS;
  use Moose;
  extends 'AWSv4';

  has prefix => (is => 'ro', init_arg => undef, isa => 'Str', default => 'k8s-aws-v1');
  has sts_url => (is => 'ro', init_arg => undef, isa => 'Str', default => 'https://sts.amazonaws.com/');

  has cluster_id => (is => 'ro', isa => 'Str', required => 1);

  has '+expires' => (default => 60);
  has '+region' => (default => 'us-east-1');
  has '+service' => (default => 'sts');
  has '+method' => (default => 'POST');
  has '+uri' => (default => '/');

  #has '+dont_sign_payload' => (default => 1);

  use URI::Escape;

  has '+params' => (lazy => 1, default => sub {
    my $self = shift;
    {
      'Action' => 'GetCallerIdentity',
      'Version' => '2011-06-15',
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
      Host => 'sts.amazonaws.com',
     'X-K8s-AWS-Id' => $self->cluster_id,
    }
  });
1;
