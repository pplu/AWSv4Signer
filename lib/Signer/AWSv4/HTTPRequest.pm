package Signer::AWSv4::HTTPRequest;
  use Moo;
  extends 'Signer::AWSv4';
  use Types::Standard qw/ClassName/;
  use HTTP::Request;

  has request => (is => 'ro', required => 1);

  has '+expires' => (default => 60);
  has '+method' => (lazy => 1, default => sub { shift->request->method });
  has '+uri' => (default => '/');

  sub build_params {
    my $self = shift;
    {
    }
  }

  sub build_headers {
    my $self = shift;
    {
    }
  }

1;
