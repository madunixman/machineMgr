package Parser;
use Moose;
use namespace::autoclean;

use DBI;
use DBD::SQLite;
use Data::Dumper;
use CLI;
use Database;

has 'id_account' 	=> (is => 'rw');
has 'host' 		=> (is => 'rw');
has 'username' 		=> (is => 'rw');
has 'password' 		=> (is => 'rw');
has 'type' 		=> (is => 'rw');
has 'home' 		=> (is => 'rw');
has 'db' 		=> (is => 'rw');


sub process(){
        my $self = shift;
	my @oarg = @{$_[0]};

	if ( $ENV{"MACHINES_DB_HOME"} ne ""){
		$self->{home} = $ENV{"MACHINES_DB_HOME"};
	} else {
		$self->{home} = $ENV{"HOME"};
		$self->{home} .= "/.machines_db";
	}
	print "Using home:[$self->{home}]\n";
	$self->{db}= $self->{home} . "/account.db";
	my $dbstring=$self->{db};
	#print "Db name: $dbstring\n";
	my $connection = Database->new();
	$connection->db($dbstring);
	if ( ! -d  $self->{home} ){
    		$connection->initialize($self->{home});
	}

	my $interactive=0;
	my $operation="";
	my $parameter="";

	if ($#oarg == 0){
		if($oarg[0] eq "-i"){
			$interactive=1;
			$operation="insert";
		}
		if($oarg[0] eq "-l"){
			$operation="list";
		}
	}
	if ($#oarg == 1){
		if($oarg[0] eq "-s"){
			$operation="search";
		}
		if($oarg[0] eq "-c"){
			$operation="connect";
		}
		if($oarg[0] eq "-d"){
			$operation="delete";
		}
		if($oarg[0] eq "-u"){
			$operation="update";
		}
		$parameter=$oarg[1];	

		my $rHash;
		if ($operation eq "search"){
			$rHash = $connection->search_by_id_account("id_account", $parameter);
		}
		if ($operation eq "connect"){
			$rHash = $connection->connect_by_id_account($parameter);
		}
		if ($operation eq "delete"){
			$rHash = $connection->delete_by_id($parameter);
		}
		if ($operation eq "update"){
			$rHash = $connection->update_i($parameter);
		}
	}
	if ($operation eq "list"){
		$connection->list();
	}

	if ($interactive && ($operation eq "insert")){
		$connection->insert_i();
	}
}

# Paolo Lulli 2017

1;
