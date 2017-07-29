#!/usr/bin/perl
use strict;
use warnings;
use IPC::Open2;
my $pid;
while (<>) {
    if ($_ =~ m/^120000 ([0-9a-f]{40}) (.*)\t(.*)/) {
	my ($obj, $stage, $path) = ($1,$2,$3);
	if (!defined $pid) {
	    $pid = open2(*Rderef, *Wderef, "git cat-file --batch-check='deref-ok %(objectname)' --follow-symlinks")
		or die "open git cat-file: $!";
	}
	print Wderef "$ENV{GIT_COMMIT}:$path\n" or die "write Wderef: $!";
	my $deref = <Rderef>;
	if ($deref =~ m/^deref-ok ([0-9a-f]{40})$/) {
	    print "100644 $1 $stage\t$path\n"
	} elsif ($deref =~ /^dangling /) {
	    # Skip next line
	    my $dummy = <Rderef>;
	} else {
	    die "Failed to parse symlink $ENV{GIT_COMMIT}:$path $deref";
	}
    } else {
	print;
    }
}
kill $pid if $pid;
exit 0;
