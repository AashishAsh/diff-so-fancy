use warnings FATAL => 'all';
my $strip_leading_indicators  = 1;
my $mark_empty_lines          = 1;
my $ansi_color_regex = qr/(\e\[([0-9]{1,3}(;[0-9]{1,3}){0,3})[mK])?/;
clean_up_input(\@input);
my ($file_1,$file_2,$last_file_seen);
	if ($line =~ /^${ansi_color_regex}diff --(git|cc) (.*?)(\s|\e|$)/) {
	} elsif ($line =~ /^$ansi_color_regex--- (\w\/)?(.+?)(\e|$)/) {
		$next    =~ /^$ansi_color_regex\+\+\+ (\w\/)?(.+?)(\e|$)/;
	} elsif ($change_hunk_indicators && $line =~ /^${ansi_color_regex}(@@@* .+? @@@*)(.*)/) {
	} elsif ($remove_file_add_header && $line =~ /^${ansi_color_regex}.*new file mode/) {
	} elsif ($remove_file_delete_header && $line =~ /^${ansi_color_regex}deleted file mode/) {
	} elsif ($clean_permission_changes && $line =~ /^${ansi_color_regex}old mode (\d+)/) {
	my ($line) = @_;
	my ($o_ofs, $o_cnt, $n_ofs, $n_cnt) = $line =~ /^@@+(?: -(\d+)(?:,(\d+))?)+ \+(\d+)(?:,(\d+))? @@+/;
	$o_cnt = 1 unless defined $o_cnt;
	$n_cnt = 1 unless defined $n_cnt;
	return ($o_ofs, $o_cnt, $n_ofs, $n_cnt);

# Remove + or - at the beginning of the lines
sub strip_leading_indicators {
	my $array = shift(); # Array passed in by reference

	foreach my $line (@$array) {
		$line =~ s/^(${ansi_color_regex})[+-]/$1 /;
	}

	return 1;
}

# Remove the first space so everything aligns left
sub strip_first_column {
	my $array = shift(); # Array passed in by reference

	foreach my $line (@$array) {
		$line =~ s/^(${ansi_color_regex})[[:space:]]/$1/;
	}

	return 1;
}

sub mark_empty_lines {
	my $array = shift(); # Array passed in by reference

	my $reset_color  = "\e\\[0?m";
	my $reset_escape = "\e\[m";
	my $invert_color = "\e\[7m";

	foreach my $line (@$array) {
		$line =~ s/^($ansi_color_regex)[+-]$reset_color\s*$/$invert_color$1 $reset_escape\n/;
	}

	return 1;
}

sub clean_up_input {
	my $input_array_ref = shift();

	# Usually the first line of a diff is whitespace so we remove that
	strip_empty_first_line($input_array_ref);

	if ($mark_empty_lines) {
		mark_empty_lines($input_array_ref);
	}

	# Remove + or - at the beginning of the lines
	if ($strip_leading_indicators) {
		strip_leading_indicators($input_array_ref);

		# Remove the first space so everything aligns left
		strip_first_column($input_array_ref);
	}


	return 1;
}

# Return git config as a hash
sub get_git_config {
	my $cmd = "git config --list";
	my @out = `$cmd`;

	my %hash;
	foreach my $line (@out) {
		my ($key,$value) = split("=",$line,2);
		$value =~ s/\s+$//;
		my @path = split(/\./,$key);

		my $last = pop @path;
		my $p = \%hash;
		$p = $p->{$_} //= {} for @path;
		$p->{$last} = $value;
	}

	return \%hash;
}