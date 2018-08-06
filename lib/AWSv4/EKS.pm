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

  sub build_params {
    my $self = shift;
    {
      'Action' => 'GetCallerIdentity',
      'Version' => '2011-06-15',
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
      Host => 'sts.amazonaws.com',
     'x-k8s-aws-id' => $self->cluster_id,
    }
  }
  });
1;
