#!/usr/bin/perl
$Path = '../'; # if $Path eq undef;
$VirtFreqPath = $Path.'VirtFreq';
$DonePath = $Path.'Done';
$ErrHPath = $Path.'ErrH';
$ErrUnknowPath = $Path.'ErrUnknow';
system "mkdir -p $VirtFreqPath";
system "mkdir -p $DonePath";
system "mkdir -p $ErrHPath";
system "mkdir -p $ErrUnknowPath";

while (1){
    opendir DIR, $Path;
    my @FileList = readdir DIR;
    close DIR;
    my @Gjf = grep /\.gjf$/, @FileList;
    my $Num = @Gjf;
    last if $Num < 1;
    my $Prefix=$Gjf[0];
    next if !(-e $Path.$Prefix);
    system "mv $Path''$Prefix ./";
    next if !(-e "$Prefix");
    my $Chk = `grep 'chk=' $Prefix`;
    $Chk=~s/^.*=//;
    $Chk=~s/\s+$//;
    $Chk='NoChk' if $Chk eq undef;
    system "g09 $Prefix";
    $Prefix=~s/\.gjf$//;
    my @LogLines = `cat $Prefix.log`;
    if (!($LogLines[-1]=~/Normal termination/)){
        my $ErrH = grep /electrons is impossible/, @LogLines;
        if ($ErrH){
            system "mv $Prefix.* $ErrHPath/";
            system "mv $Chk $ErrHPath/$Prefix.chk" if -e "$Chk";
        } else {
	    system "mv $Prefix.* $ErrUnknowPath/";
            system "mv $Chk $ErrUnknowPath/$Prefix.chk" if -e "$Chk";
	}
    } else {
        shift @LogLines while (!($LogLines[0]=~/and normal coordinates:/));
        my $Freq1 = (split /\s+/, $LogLines[3])[3];
        if ($Freq1 < 0){
            system "mv $Prefix.* $VirtFreqPath/";
            system "mv $Chk $VirtFreqPath/$Prefix.chk" if -e "$Chk";
        } else {
            system "mv $Prefix.* $DonePath/";
            system "mv $Chk $DonePath/$Prefix.chk" if -e "$Chk";
        }
    }
}
