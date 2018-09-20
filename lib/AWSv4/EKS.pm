package AWSv4::EKS;
  use Moo;
  extends 'AWSv4';
  use Types::Standard qw/Str/;

  use JSON::MaybeXS qw//;
  use MIME::Base64 qw//;

  has prefix => (is => 'ro', init_arg => undef, isa => Str, default => 'k8s-aws-v1');
  has sts_url => (is => 'ro', init_arg => undef, isa => Str, default => 'https://sts.amazonaws.com/');

  has cluster_id => (is => 'ro', isa => Str, required => 1);

  has '+expires' => (default => 60);
  has '+region' => (default => 'us-east-1');
  has '+service' => (default => 'sts');
  #has '+method' => (default => 'POST');
  has '+method' => (default => 'GET');
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

  has qstring_64 => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    MIME::Base64::encode_base64url($self->signed_qstring);
  });

  has token => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->prefix . '.' . MIME::Base64::encode_base64url($self->sts_url) . '_' . $self->qstring_64;
  });

  has k8s_json => (is => 'ro', isa => Str, init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    JSON::MaybeXS::encode_json({
      kind => 'ExecCredential',
      apiVersion => 'client.authentication.k8s.io/v1alpha1',
      spec => {},
      status => {
        token => $self->token,
      }
    });
  });

1;
