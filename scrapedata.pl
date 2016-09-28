
#!/usr/bin/perl
##########################################################################
# generate-data_js.pl - Generate data.js for dotabuffcp                  #
# Copyright (C) <2014>  Onur Aslan  <onuraslan@gmail.com>                #
#                                                                        #
# See COPYING for distribution information.                              #
##########################################################################


use strict;
use warnings;
use LWP::Simple;
use JSON;
use POSIX qw/strftime/;


my $DEBUG = 1;
my @heroes;
my @heroes_bg;
my @heroes_wr;
my @win_rates;


sub read_data {
  my $content = '';
  $content .= $_ while (<DATA>);
  return $content;
}


sub hero_link {
  my $hero = $_[0];
  $hero =~ s/'//g;
  $hero =~ s/ /-/g;
  $hero =~ tr/[A-Z]/[a-z]/;
  return $hero;
}


sub hero_id {
  my $hero = $_[0];

  my $c = 0;
  for (@heroes) {
    return $c if ($_ eq $hero);
    ++$c;
  }
  return -1;
}


sub get_heroes {

  $DEBUG and warn "Getting hero list\n";

  my $content = get ('http://dotabuff.com/heroes') or die;
  (@heroes_bg) = $content =~ /background: url\((.*?)\)/g;
  (@heroes) = $content =~ /<div class="name">(.*?)<\/div>/g;
  $_ =~ s/&.*?;// for (@heroes);
  $_ =~ s/&#47;/\//g for (@heroes_bg);
}



sub get_winrates_of_hero {
  my ($hero, $hid) = ($_[0], hero_id ($_[0]));

  $DEBUG and warn "Getting winrates of $hero\n";

  my $content = get ('http://dotabuff.com/heroes/' .
                     hero_link ($hero) .
                     '/matchups?date=patch_6.86d') or die;
  
  my $file_location = "/home/erick/Dropbox/erick/dotaproj/postpycon/heropages/$hero";
  open my $file, '>', $file_location or die $!;
  print $file $content;
  close $file;
  
}


sub get_winrates {
  get_winrates_of_hero ($_) for (@heroes);
}


sub print_winrates {
  my $json = JSON->new;

  $DEBUG and warn "Writing win rates to data.js\n";

  open my $fh, '>data.js';

  print $fh 'var heroes = ', $json->encode ([ @heroes ]);
  print $fh ', heroes_bg = ', $json->encode ([ @heroes_bg ]);
  print $fh ', heroes_wr = ', $json->encode ([ @heroes_wr ]);
  print $fh ', win_rates = ', $json->encode ([ @win_rates ]);
  print $fh ', update_time = "',
               strftime("%Y-%m-%d", localtime (time ())),
               "\";\n";
  close $fh;
}


$_ eq '--debug' and $DEBUG++ for @ARGV;

get_heroes ();
get_winrates ();
print_winrates ();

__DATA__
