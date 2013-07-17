#Markov generator

use strict;
use warnings;

sub read_file {
	my $file = shift;
	open my $f, $file or die "Couldn't open $file: $!\n";
	my $subref = \&triple_line;
	while (my $line = <$f>) {
		$subref->($line);
	}
}

sub triple_line {
	my @word_list = split " ", shift;
	my $subref = \&triple_word;
	foreach my $word (@word_list) {
		$subref->($word);
	}
}

sub triple_word {
	our @prefix;
	our %wordmap;
	my $word = shift;
	if (@prefix == 2) {
		my $key = join " ", @prefix;
		my $aref = $wordmap{$key};
		push @$aref, $word;
		$wordmap{$key} = $aref;
		#print "@prefix => $word\n";
		shift @prefix;
	}
	push @prefix, $word;
}

sub generator {
	our %wordmap;
	my $file = shift;
	my $iterations = shift || 100;
	my $subref = \&read_file;
	$subref->($file);
	my $subref = \&rand_elt;
	my $current_prefix = $subref->(keys %wordmap);
	print "$current_prefix ";
	for (my $i = 0; $i < $iterations; $i++) {
		my $nextword_ref = $wordmap{$current_prefix};
		if (defined($nextword_ref)) {
			print "@$nextword_ref ";
			my @prefix_array = split " ", $current_prefix;
			shift @prefix_array;
			$current_prefix = "@prefix_array @$nextword_ref";
		} else {
			$current_prefix = $subref->(keys %wordmap);
		}
		
	}
}

sub rand_elt {
	$_[rand @_]
}

generator @ARGV;