package RTBM;

use v5.10.1;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::Method::Signatures;
use Config::Tiny;
use Carp;

extends 'WebService::RTMAgent';

# After we build our object, auto-init with RTM.

sub BUILD {
    my ($self) = @_;

    my $config = Config::Tiny->read("$ENV{HOME}/.rtbmrc");
    $config or die "Can't read ~/.rtbmrc config file";

    $self->api_key(    $config->{RTBM}{api_key}    );
    $self->api_secret( $config->{RTBM}{api_secret} );

    $self->init;

    return;
}

method lists {
    my $lists = $self->lists_getList
        or croak $self->error;

    # Unpack lists from our data structure.
    return $lists->{lists}[0]{list};
}

method find_list (Str $listname) {
    my $lists = $self->lists;

    foreach my $list (@$lists) {
        return $list if lc($list->{name}) eq lc($listname);
    }

    croak "$listname not found";
}

method get_inbox {
    my $inbox_id = $self->find_list('Inbox')->{id};

    my $tasks = $self->tasks_getList("list_id=$inbox_id", 'filter=status:incomplete');

    # Unpacking again...
    return $tasks->{tasks}[0]{list}[0]{taskseries};
}

1;
