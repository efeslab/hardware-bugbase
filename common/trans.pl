#!/usr/bin/perl -w

use warnings;
use strict;

use lib 'blib/lib';
use Verilog::EditFiles;
use FindBin qw($RealBin $RealScript $Script);

my $split = Verilog::EditFiles->new
    (outdir => ".",
     translate_synthesis => 0,
     lint_header => undef,
     celldefine => 1,
     );

$split->edit_file(
        filename=>@ARGV,
    cb=>sub {
         my $wholefile = shift;
         my $lint = "/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
/*verilator lint_off PINMISSING*/
/*verilator lint_off TIMESCALEMOD*/
",
         $wholefile =~ s%(\btri[01]\b)(.*)%logic$2 // -- converted tristate to logic%g;
         $wholefile =~ s%(buf\s*\(\s*(\w+)\s*,\s*(\w+)\));%assign $2 = $3; // -- converted buf to assign%g;
         $wholefile =~ s%1'b[xz]%1'b0 /* converted x or z to 1'b0 */%g;
         return $lint.$wholefile;
});

