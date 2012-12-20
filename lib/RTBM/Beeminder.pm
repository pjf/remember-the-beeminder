package RTBM::Beeminder;

use Moose;
use Config::Tiny;

extends 'WebService::Beeminder';

my $config = Config::Tiny->read("$ENV{HOME}/.rtbmrc");
$config or die "Can't read ~/.rtbmrc config file";

has '+token' => (
	default => $config->{Beeminder}{auth_token},
);

no Moose;

1;
