package AWSv4;
  use Moose;
  use Time::Piece;
  use Digest::SHA qw//;

  has access_key => (is => 'ro', isa => 'Str', required => 1);
  has secret_key => (is => 'ro', isa => 'Str', required => 1);
  has method => (is => 'ro', isa => 'Str', required => 1);
  has uri => (is => 'ro', isa => 'Str', required => 1);
  has region => (is => 'ro', isa => 'Str', required => 1);
  has service => (is => 'ro', isa => 'Str', required => 1);

  has expires => (is => 'ro', isa => 'Int', required => 1);

  has time => (is => 'ro', isa => 'Time::Piece', default => sub {
    localtime;
  });

  has date => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->time->ymd('');
  });

  has date_timestamp => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->time->ymd('') . 'T' . $self->time->hms('') . 'Z';
  });

  has params  => (is => 'ro', isa => 'HashRef', default => sub { {} });
  has headers => (is => 'ro', isa => 'HashRef', default => sub { {} });
  has content => (is => 'ro', isa => 'Str', default => '');
  has dont_sign_payload => (is => 'ro', isa => 'Bool', default => 0);

  has canonical_qstring => (is => 'ro', isa => 'Str', lazy => 1, default => sub {
    my $self = shift;
    join '&', map { $_ . '=' . $self->params->{ $_ } } sort keys %{ $self->params };
  });

  has header_list => (is => 'ro', isa => 'ArrayRef', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    [ sort keys %{ $self->headers } ];
  });

  has canonical_headers => (is => 'ro', isa => 'Str', lazy => 1, default => sub {
    my $self = shift;
    join '', map { lc( $_ ) . ":" . $self->headers->{ $_ } . "\n" } @{ $self->header_list };
  });

  has hashed_payload => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    if ($self->dont_sign_payload) {
      return 'UNSIGNED-PAYLOAD'
    } else {
      return Digest::SHA::sha256_hex($self->content);
    }
  });

  has signed_header_list => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join ';', map { lc($_) } @{ $self->header_list };
  });

  has canonical_request => (is => 'ro', isa => 'Str', lazy => 1, default => sub {
    my $self = shift;
    join "\n", $self->method,
               $self->uri,
               $self->canonical_qstring,
               $self->canonical_headers,
               $self->signed_header_list,
               $self->hashed_payload;
  });

  has credential_scope => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join '/', $self->date, $self->region, $self->service, 'aws4_request';
  });

  has aws_algorithm => (is => 'ro', isa => 'Str', init_arg => undef, default => 'AWS4-HMAC-SHA256');

  has string_to_sign => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    join "\n", $self->aws_algorithm,
               $self->date_timestamp,
               $self->credential_scope,
               Digest::SHA::sha256_hex($self->canonical_request);
  });

  has signing_key => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    my $kSecret = "AWS4" . $self->secret_key;
    my $kDate = Digest::SHA::hmac_sha256($self->date, $kSecret);
    my $kRegion = Digest::SHA::hmac_sha256($self->region, $kDate);
    my $kService = Digest::SHA::hmac_sha256($self->service, $kRegion);
    return Digest::SHA::hmac_sha256("aws4_request", $kService);
  });

  has signature => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    Digest::SHA::hmac_sha256_hex($self->string_to_sign, $self->signing_key);
  });

  has signed_qstring => (is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub {
    my $self = shift;
    $self->canonical_qstring . '&X-Amz-Signature=' . $self->signature;
  });

1;
