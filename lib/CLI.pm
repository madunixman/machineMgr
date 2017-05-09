package CLI;
use Moose;
use namespace::autoclean;

has value => ( is => 'rw', isa => 'Str',);

sub prompt($){
	my $self = shift;
	my $name = shift;

        print ("Insert [$name]: ");
        my $ret=<STDIN>;
        chomp($ret);
        $self->{value} = $ret;
	return $self->{value};
}

# Paolo Lulli 2017

1;
