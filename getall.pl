#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use File::Touch;
use DateTime::Format::DateParse;
use File::Slurp;
use Geo::METAR;
use POSIX qw(strftime);
use GD::Graph::linespoints;

my $baseurl = "http://tgftp.nws.noaa.gov/data/observations/metar/cycles";
my $icao = "KEQY";

my $pad = 0.02;

my %files; # hash of {filename}=modifiedtime
for (my $i = 0; $i < 24; $i++) {
	# Determine the file name: nnZ.TXT
	my $file = sprintf('%02dZ.TXT', $i);
	print("$file ");
	# Download the file
	if (time > ((stat($file))[9] + 24 * 60 * 60)) {
		print("downloading...");
		getFile("$baseurl/$file", $file);
		print("done.\n");
		# Read the first line, it contains the timestamp of the reading for the first location in the file
		open F, $file or die "$! $file";
		my $line = <F>;
		close F;
		# Clean it up and add a timezone (UTC)
		$line =~ s/\n$//;
		$line = "$line +0000";
		# Parse it into a DateTime object and change the timezone
		my $dt = DateTime::Format::DateParse->parse_datetime($line);
		$dt->set_time_zone('America/New_York');
		# Update the modified time on the file to match
		my $touch_obj = File::Touch->new( mtime => $dt->epoch );
		my $count = $touch_obj->touch($file);
		$files{$file} = $dt->epoch;
	} else {
		$files{$file} = (stat($file))[9];
		print("OK\n");
	}
}

print("\n");
# Run through the files in order by modified time,
#  find the records for the desired station,
#  and stick them in a hash
my %observations;
foreach my $name (sort { $files{$a} <=> $files{$b} } keys %files) {
	my $contents = read_file($name);
	my @matches = ($contents =~ /(?:^|\n)(KEQY [^\n]+)/g);
	foreach my $match (@matches) {
		my $m = new Geo::METAR;
		$m->metar($match);
		my $dt = DateTime::Format::DateParse->parse_datetime(strftime("%Y-%m-", gmtime($files{$name})) . $m->DATE . " " . $m->TIME);
		$observations{$dt->epoch} = $m->ALT;
	}
}

my @points;
my @values;
my $minobs = 500;
my $maxobs = 0;
foreach my $observation (sort keys %observations) {
	#print($observations{$observation} . " observed at $observation\n");
	my $dt = DateTime->from_epoch( epoch => $observation, time_zone => 'UTC' );
	$dt->set_time_zone('America/New_York');
	my $obtime = $dt->hour_1 + $dt->minute / 60;
	push @points, $dt->hour_1();
	push @values, $observations{$observation};
	if ($minobs > $observations{$observation}) {
		$minobs = $observations{$observation};
	}
	if ($maxobs < $observations{$observation}) {
		$maxobs = $observations{$observation};
	}
	#print($observations{$observation} . " observed at " . $obtime . "\n");
}

my @data;
push @data, \@points, \@values;
my $my_graph = new GD::Graph::linespoints( );
$my_graph->set(
	title => 'Barometric Pressure History',
	x_label	=> 'Hourly Readings',
	y_label => 'Inches',
	y_min_value => ($minobs - $pad),
	y_max_value => ($maxobs + $pad),
);
$my_graph->set_legend( 'Barometric Pressure' );
my $gd = $my_graph->plot(\@data);
write_file( "$icao.png", $gd->png() );

exit;

sub getFile() {
	my ($url, $fname) = @_;
	# Download the file
	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new(GET => "$url");
	my $r = $ua->request($req)->content;
	# Write it
	write_file($fname, $r);
}
