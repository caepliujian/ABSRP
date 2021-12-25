#!/usr/bin/perl
#March/8/2021/10AM by Liu Jian
$nproc = $ARGV[0];
$mem = $ARGV[1];
$file = $ARGV[2];
$file =~ s/\s+$//;
die "Usage: ThisScript nproc mem molfile(prefix.xyz or prefix.mol)!!!\n" if $mem eq undef;
die "ERROR: unmatched format!!!" if !($file =~ /\.mol/ or $file =~ /\.xyz/ or $file =~ /\.gjf/ or $file =~ /\.com/ or $file =~ /\.gjf/);
$natom;
$spin="0 1";
$prefix = $file;
@Levels = &ImportLevels;
$Format = (split /\./, $file)[-1];
@gjf = &GetAtoms;
for  (@Levels){
    &BuildGjf($_) if ($natom > 0);
}


sub ImportLevels{
    my @Levels;
    if (-e "INPUT.txt"){
        open IN, "< INPUT.txt";
        my @InputLevels = <IN>;
        close IN;
        for my $Level (@InputLevels){
            $Level=~s/\s+$//;
            push @Levels, $Level;
        }
    } else {
        push @Levels, '#P OPT Freq M062X/6-31+G(2df,p) INT=UltraFine';
    }
    return @Levels;
}


sub GetAtoms{
    open FL, "< $file" or die "Error $file missing!!!\n";
    my @gjf=<FL>;
    close FL;
    if ($Format eq 'mol'){
        $prefix =~ s/\.mol$//;
        my @tmp = split /\./, $prefix;
	    my $IsRadical = $tmp[1];
        $IsRadical = 1 if ($tmp[0] eq 'no2' or $tmp[0] eq 'NO2');
	    $spin = '0 2' if $IsRadical;
        shift @gjf for (1 .. 3);
        $natom = (split /\s+/, $gjf[0])[1];
        shift @gjf;
    }
    if ($Format eq 'xyz'){
        $prefix =~ s/\.xyz$//;
        $natom = (split /\s+/, $gjf[0])[0];
        shift @gjf for (1 .. 2);
    }
    if ($Format eq 'com' or $Format eq 'gjf'){
        $prefix =~ s/\.gjf$//;
        $prefix =~ s/\.com$//;
        shift @gjf while (!($gjf[0]=~/^[0-9] [0-9]/));
        $spin = shift @gjf;
	    $spin=~s/\s+$//;
        my @tmpgjf;
        $natom = 0;
        while ((split /\s+/, $gjf[0])[1] ne undef){
            $natom++;
            push @tmpgjf, (shift @gjf);
        }
        @gjf =  @tmpgjf;
    }
    return @gjf;
}


sub BuildGjf{
    my $level = shift @_;
    my $ShortLevel = &ShortLevel($level);
    print "$ShortLevel\t$prefix\n";
    open GJF, "> $ShortLevel.$prefix.gjf";
    printf GJF "%%nproc=$nproc\n";
    printf GJF "%%mem=$mem\GB\n";
#    printf GJF "%%chk=$ShortLevel.$prefix.chk\n";
    printf GJF "$level\n\n";
    printf GJF "$prefix\n\n";
    printf GJF $spin."\n";
    for (0 .. $natom - 1){
        my $line = $gjf[$_];
        if ($Format eq 'mol'){
            $line=~s/^\s+//;
            $line=~s/\s+$//;
            my @line = split /\s+/, $line;
	    printf GJF "%-4s%8.4f%8.4f%8.4f\n", $line[3], $line[0], $line[1], $line[2];
            }
            if ($Format eq 'xyz' or $Format eq 'gjf' or $Format eq 'com'){
                printf GJF $line;
            }
	}
    printf GJF "\n";
    printf GJF "\$nbo bndidx \$end\n\n" if $level=~/NBORead/;
    close GJF;
} 


sub ShortLevel{
    my $Str = shift @_;
    my $D3='GD3' if $Str=~/=gd3/ or $Str=~/=GD3/;
    if ($Str=~/G[1-4]/){
        my @Tmp = split /\s+/, $Str;
        for (@Tmp){
            $Str = $_ if $_=~/G[1-4]/;
        }
    } else {
        if ($Str=~/CBS/){
            $Str=~s/^.*CBS/CBS/;
	        $Str=~s/\s+$//;
        } else {
	        my @Str = split /\s+/, $Str;
	        $Str = shift @Str;
	        while (!($Str=~/\//)){
	            $Str = shift @Str;
	        }
	        $Str=~s/\///;
            $Str=~s/\,//;
	        $Str=~s/\*/x/g;
	        $Str=~s/\+/x/g;
	        $Str=~s/\(//;
            $Str=~s/\)//;
        }
    }
    return $Str.$D3;
}
