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

    # decode the POST payload into a hash representing the parameters
    my @params = split(/&/, $self->request->content);
    return {
      map { split /=/, $_ } @params
    }
  }

  sub build_headers {
    my $self = shift;

    my $h = {};
    $self->request->headers->scan(sub { $h->{ $_[0] } = $_[1] });
    return $h;
  }

1;
