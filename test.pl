#!/usr/bin/env perl

my $PI = 4 * atan2(1, 1);

sub ptmetafun_cos3y {
	my $y = shift;
	return ((1 + cos(3*$y)) / 2)
}

sub ptmetafun_hemispheres {
	my $y = shift;
	if ($y <= $PI / 2) {
		return 1;
	} else {
		return 0;
	}
}

sub sphere {
	my $r = shift;
	my $samples_theta = shift;
	my $samples_phi = shift;
	my $ptmetafun = shift;

	my $theta_max = $PI;
	my $phi_max = 2*$PI;

	my @pts;
	for ($j = 0; $j < $samples_theta; ++$j) {
		my $theta = $theta_max*$j/($samples_theta - 1);
		my $z = cos($theta);
		my $rxy = sin($theta);

		my @row;
		for($i = 0; $i < $samples_phi; ++$i) {
			my $phi = $phi_max*$i/($samples_phi - 1);
			my $x = $rxy*cos($phi);
			my $y = $rxy*sin($phi);

			# Normalize k cos 3 theta to [0, 1]
			# my $V = (1 + cos(3*$theta)) / 2;
			my $V = &$ptmetafun($theta);
			push @row, [$x, $y, $z, $V];
		}

		push @pts, [ @row ];
	}

	return @pts;
}

open(my $dat, ">", "pts.dat") or die "Can't open pts.dat $!!\n";
open(my $tbl, ">", "pts.table") or die "Can't open pts.table: $!!\n";

sub printpts {
	print $tbl "x y z c\n";
	foreach(@_) {
		foreach(@$_) {
			print $tbl "@$_[0] @$_[1] @$_[2] @$_[3]\n";
		}
	}
}

sub printind {
	my $samples_theta = shift;
	my $samples_phi = shift;
	for($j = 0; $j < $samples_theta-1; ++$j) {
		my $rowsprev = $samples_phi * $j;
		for($i = 0; $i < $samples_phi; ++$i) {
			my $p0 = $rowsprev + $i;
			my $p1 = $rowsprev + (($i + 1) % $samples_phi);
			my $p2 = $p1 + $samples_phi;
			my $p3 = $p0 + $samples_phi;
			print $dat "$p0 $p1 $p2 $p3\n";
		}
	}
}

my $samplesy=16;
my $samplesx=16;
my @points = sphere(1, $samplesy, $samplesx, \&ptmetafun_hemispheres);

printpts @points;
printind ($samplesy, $samplesx);


