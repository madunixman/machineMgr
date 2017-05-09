package Database;
use Moose;
use namespace::autoclean;

use DBI;
use DBD::SQLite;
use Data::Dumper;
use CLI;

has db 		=> ( is => 'rw', isa => 'Str',);
has id_account 	=> ( is => 'rw', isa => 'Str',);
has host 	=> ( is => 'rw', isa => 'Str',);
has username 	=> ( is => 'rw', isa => 'Str',);
has password 	=> ( is => 'rw', isa => 'Str',);
has type 	=> ( is => 'rw', isa => 'Str',);
has home 	=> ( is => 'rw', isa => 'Str',);

my $cli = CLI->new;
my $dbs=$ENV{"HOME"}."/.machines_db/account.db";
     
sub initialize($){
        my $self = shift;
        my $homedir = shift;
    	mkdir($homedir);
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	$dbh->do("PRAGMA foreign_keys = ON");
	my $sql;
	my $sth;

	print "Create table [account_type]\n";
	$sql = "create table account_type( id_account_type text, name text, description text )"; 
	$sth = $dbh->prepare($sql);
	$sth->execute;

	print "Create table [account]\n";
	$sql = "create table account( id_account text, host text, username text, password text, type text)"; 
	$sth = $dbh->prepare($sql);
	$sth->execute;
}

sub insert_i(){
        my $self = shift;
	my $cli = CLI->new;
     	$self->{id_account}=$cli->prompt('id_account');
     	$self->{host}=$cli->prompt('host');
     	$self->{username}=$cli->prompt('username');
     	$self->{password}=$cli->prompt('password');
     	$self->{type}=$cli->prompt('type');
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	#$dbh->do("PRAGMA foreign_keys = ON");
	my $sql = "insert into account(id_account, host, username, password, type ) values (?,?,?,?,?) ";
	my $sth = $dbh->prepare($sql);
    	$sth->bind_param(1, $self->{id_account});
    	$sth->bind_param(2, $self->{host});
    	$sth->bind_param(3, $self->{username});
    	$sth->bind_param(4, $self->{password});
    	$sth->bind_param(5, $self->{type});
	$sth->execute || die("id_account: [$self->{id_account}] already exists");
}

sub update_i($){
        my $self = shift;
     	my $id_account=$_[0];
   	$self->{host}=$cli->prompt('host');
        $self->{username}=$cli->prompt('username');
        $self->{password}=$cli->prompt('password');
        $self->{type}=$cli->prompt('type');
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	#$dbh->do("PRAGMA foreign_keys = ON");
	my $sql = "update account set  host=?, username=?, password=?, type=?  where id_account = ? ";
	my $sth = $dbh->prepare($sql);
    	$sth->bind_param(1, $self->{host});
    	$sth->bind_param(2, $self->{username});
    	$sth->bind_param(3, $self->{password});
    	$sth->bind_param(4, $self->{type});
    	$sth->bind_param(5, $self->{id_account});
	$sth->execute || die("id_account: [$id_account] does not exists");
}
sub get_by_id_account($){
        my $self = shift;
     	my $id_account=$_[0];
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	#$dbh->do("PRAGMA foreign_keys = ON");

	my $sql = "select id_account, host, username, password, type from account where id_account = ? ";
	my $sth = $dbh->prepare($sql);
    	$sth->bind_param(1, $id_account);
	$sth->execute;
	my $hash = $sth->fetchall_hashref('id_account');
	return $hash;
}
sub delete_by_id($){
        my $self = shift;
     	my $id_account=$_[0];
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	#$dbh->do("PRAGMA foreign_keys = ON");
	my $sql = "delete from account where id_account = ? ";
	my $sth = $dbh->prepare($sql);
    	$sth->bind_param(1, $id_account);
	$sth->execute;
}
sub search_by_field($$){
        my $self = shift;
     	my $field=$_[0];
     	my $value=$_[1];
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	$dbh->do("PRAGMA foreign_keys = ON");
	my $sql = "select id_account, host, username, password, type from account where $field like ? ";
	my $sth = $dbh->prepare($sql);
    	$sth->bind_param(1, $value);
	$sth->execute;
	my $hash = $sth->fetchall_hashref('id_account');
	return $hash;
}

sub select_all(){
        my $self = shift;
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbs","","");
  	$dbh->do("PRAGMA foreign_keys = ON");
	my $sql = "select id_account, host, username, password, type from account";
	my $sth = $dbh->prepare($sql);
    	$sth->bind_param(1, $self->{id_account});
	$sth->execute;
	my $hash = $sth->fetchall_hashref('id_account');
	return $hash;
}

sub list(){
        my $self = shift;
	my $list = &select_all();
	my $key;
	foreach $key ( keys(%{$list}) ) {
    		print "$list->{$key}->{'id_account'}\t:\t";
    		print "$list->{$key}->{'username'}\@$list->{$key}->{'host'}";
    		print "($list->{$key}->{'type'})\n";
	}
}

#sub search(){
sub search_by_id_account($){
	my $value = $_[0];
	my $list = &search_by_field('id_account',$value);
	my $key;
	foreach $key ( keys(%{$list}) ) {
    		print "$list->{$key}->{'id_account'}\t:\t";
    		print "$list->{$key}->{'username'}\@$list->{$key}->{'host'}";
    		print "($list->{$key}->{'type'})\n";
	}
}
sub connect_by_id_account($){
	my $id_account=$_[0];
	my $infos = &get_by_id_account($id_account);
	my $command = "ssh $infos->{$id_account}->{'username'}\@$infos->{$id_account}->{'host'}\n";
	print "=============================================================\n";
	print "ssh $infos->{$id_account}->{'username'}\@$infos->{$id_account}->{'host'} with password: [$infos->{$id_account}->{'password'}]\n";
	print "=============================================================\n";
	system($command);

}


1;
