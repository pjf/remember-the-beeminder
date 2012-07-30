package RTBM;

use v5.10.1;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::Method::Signatures;
use Config::Tiny;
use Carp;

extends 'WebService::RTMAgent';

# Shouldn't really be rw, but I'm lazy and this lets me set it
# in BUILD.
has '_config' => (is => 'rw', isa => 'Config::Tiny');

# After we build our object, auto-init with RTM.

sub BUILD {
    my ($self) = @_;

    my $config = Config::Tiny->read("$ENV{HOME}/.rtbmrc");
    $config or die "Can't read ~/.rtbmrc config file";

    # Save our config for later use.
    $self->_config($config);

    # Configure our RTM settings.
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

method lists_by_id {
    state $lists_by_id;

    # Return lists if already cached.
    return $lists_by_id if $lists_by_id;

    # Otherwise build hash.
    my $lists = $self->lists;

    foreach my $list (@$lists) {
        $lists_by_id->{ $list->{id} } = $list->{name};
    }

    return $lists_by_id;
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

# Date can be 'today', 'yesterday', etc.
method get_done (Str $date) {
    my $done = $self->tasks_getList("filter=completed:$date");

    return $done->{tasks}[0]{list};
}

# Given a task and its list, returns how many points it's worth
method score(HashRef $task, Str $list) {
    state $scoring_table = $self->_config->{Scores};

    my $score = $scoring_table->{DEFAULT};  # We start with the default score

    $score = $scoring_table->{$list} // $score;   # Use list score, if exists

    # Tags override lists, and we take the highest scoring tag on a task.

    my $tag_score;

    # Walk through my tags, remember score if applicable.

    foreach my $tag (@{ $task->{tags}[0]{tag} || [] }) {
        no warnings 'uninitialized';
        if ($scoring_table->{$tag} >= $tag_score) {
            $tag_score = $scoring_table->{$tag};
        }
    }

    $score = $tag_score // $score;  # Take tag score if it was found

    return $score;

}

1;
