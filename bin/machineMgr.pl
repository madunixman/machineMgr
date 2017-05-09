use strict;
use warnings;
use v5.10;
 
if ($#ARGV == -1){
        foreach(<DATA>){
                print;
        }
        exit(0);
}

use Parser;
my $options = Parser->new;
$options->process(\@ARGV);


__DATA__

machineMgr -i 			: insert a new machine data
machineMgr -s 	<string> 	: search string in the id_account name
machineMgr -S 	<host|username|password|type> <string> 	: search string in the parameter host,username,etc.. provided string
machineMgr -c 	<id_account>	: connect to <id_account>
machineMgr -u 	<id_account>	: update <id_account>
machineMgr -d 	<id_account>	: delete <id_account>
machineMgr -l 			: list available id_accounts

# Paolo Lulli 2017
