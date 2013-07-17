#Markov generator
#Usage: perl markov_generator.pl <input_file.txt> [<num_iterations>]

use strict;
use warnings;

sub read_file {
	# Reads a file line-by-line and calls the sub
	# get_words on each line.
	my $file = shift;
	open my $f, $file or die "Couldn't open $file: $!\n";
	while (my $line = <$f>) {
		&get_words($line);
	}
	#print $text;
}

sub get_words {
	# Splits a line into an array of words, and calls
	# create_wordmap on each word.
	my @word_list = split " ", shift;
	foreach my $word (@word_list) {
		&create_wordmap($word);
	}
}

sub create_wordmap {
	# Takes a word as a parameter and adds it to the 
	# global array "keyphrase". When the keyphrase is two words
	# long, it is converted to a string and stored as a key in 
	# the global hash "wordmap". The value associated with the 
	# keyphrase is a reference to the array of words that immediately 
	# following the keyphrase in the input file.
	our @keyphrase;
	our %wordmap;
	my $word = shift;
	if (@keyphrase == 2) {
		my $key = join " ", @keyphrase;
		my $aref = $wordmap{$key};
		push @$aref, $word;
		$wordmap{$key} = $aref;
		#print "@keyphrase => $word\n";
		shift @keyphrase;
	}
	push @keyphrase, $word;
}

sub rand_elt {
	# Picks a random element from an array.
	$_[rand @_]
}

sub generator {
	# Takes a filename as a required argument and the number of 
	# iterations as an optional argument, calls read_file on the file,
	# and uses the resulting wordmap to generate random text. 
	our %wordmap;
	my $file = shift;
	my $iterations = shift || 250;
	
	&read_file($file);
	
	my $current_keyphrase = &rand_elt(keys %wordmap);
	print "$current_keyphrase ";
	
	for (my $i = 0; $i < $iterations; $i++) {
		my $nextword_ref = $wordmap{$current_keyphrase};
		if (defined($nextword_ref)) {
			my $nextword = &rand_elt(@$nextword_ref);
			print "$nextword ";
			my @keyphrase_array = split " ", $current_keyphrase;
			shift @keyphrase_array;
			$current_keyphrase = "@keyphrase_array $nextword";
		} else {
			print "\n\nBroke after $i iterations";
			last;
		}
		
	}
}

generator @ARGV;