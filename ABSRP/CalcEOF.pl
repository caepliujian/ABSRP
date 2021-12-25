#!/usr/bin/perl
&Run_CalcEOF(@ARGV);


sub Run_CalcEOF{
    my $ScriptPath = shift;
    my $LogFile = shift;
    my $FragDir = './';
    my $DeltaCBH = &GetDeltaCBH($ScriptPath.'EnthalpyLibrary/', $LogFile, $FragDir);
    #printf "%.6f", $DeltaCBH;
    my ($ShortLevel, $Mol, $MolEnthalpyLo, %NumAtom) = &ReadFromLog($LogFile);
    my $MolEnthalpyHi = $MolEnthalpyLo + $DeltaCBH;
    my $EOF = &CalcG4EOF($MolEnthalpyHi, %NumAtom);
    printf "$LogFile,%.2f\(kcal\/mol\)\n", $EOF*627.5095;
}


sub ReadFromLog(){
    my $Mol = shift @_;
    my %NumAtom;
    open LOG, "< $Mol";
    my @log = <LOG>;
    close LOG;
    shift @log while !($log[0]=~/Symbolic Z-matrix:/);
    shift @log for (1 .. 2);
    while (@log){
	    my $line= shift @log;
	    $line=~s/^\s+//;
	    last if $line eq undef;
	    my @line = split /\s+/, $line;
	    $NumAtom{$line[0]}++;
    }
    my $ShortLevel = (split/\./, $Mol)[0];
    $Mol=~s/^$ShortLevel\.//;
    $Mol=~s/\.log$//;
    my $line = (grep /G4 Enthalpy=/, @log)[-1];
    $line = (grep /Sum of electronic and thermal Enthalpies=/, @log)[-1] if $line eq undef;
    die "No Output for Thermal Enthalpy in $log\n" if $line eq undef;
    my $Enthalpy = (split /=/, $line)[1];
    $Enthalpy=~s/^\s+//;
    $Enthalpy=~s/\s+.*$//;
    $Enthalpy=~s/\s+$//;
    $Enthalpy = '9999' if $line eq undef;
    return ($ShortLevel, $Mol, $Enthalpy, %NumAtom);
}


sub GetDeltaCBH{
    my $LibPath = shift;
    my $LogFile = shift;
    die "GetDeltaCBH****ERROR: No log file!!!\n" if $LogFile eq undef;
    my $FragDir = shift;
    die "GetDeltaCBH****ERROR: No path defined for fragment files!!!\n" if $FragDir eq undef;
    (my $ShortLevel, my $Prefix, my %NumAtom) = &ParameterFromLog($LogFile);
    my %LibLoLevel = &ReadEnthalpyLib($LibPath,$ShortLevel);
    my %LibHiLevel = &ReadEnthalpyLib($LibPath,'G4');
    my @MissingSmiHi = &ChkMissingFrag($FragDir, $Prefix, keys %LibHiLevel);
    my @MissingSmiLo = &ChkMissingFrag($FragDir, $Prefix, keys %LibLoLevel);
    if ((@MissingSmiHi,@MissingSmiLo) > 0){
        print "\nGetDeltaCBH****ERROR for missing G4 Enthalpies of follows:\n" if @MissingSmiHi;
        print $_."," for @MissingSmiHi;
        print "\n";
        print "\nGetDeltaCBH****ERROR for missing $ShortLevel Enthalpies of follows:\n" if @MissingSmiLo;
        print $_."," for @MissingSmiLo;
        print "\n";
        return;
    }
    my $SumEHiProd = &GetSumEnthalpy($FragDir.$Prefix.'.prod', %LibHiLevel);
    my $SumEHiReac = &GetSumEnthalpy($FragDir.$Prefix.'.Reac', %LibHiLevel);
    my $SumELoProd = &GetSumEnthalpy($FragDir.$Prefix.'.prod', %LibLoLevel);
    my $SumELoReac = &GetSumEnthalpy($FragDir.$Prefix.'.Reac', %LibLoLevel);
    my $DeltaCBH = ($SumEHiProd - $SumELoProd - $SumEHiReac + $SumELoReac);
    return $DeltaCBH;
}


sub ParameterFromLog(){
    my $Mol = shift @_;
    my %NumAtom;
    open LOG, "< $Mol";
    my @log = <LOG>;
    close LOG;
    shift @log while !($log[0]=~/Symbolic Z-matrix:/);
    shift @log for (1 .. 2);
    while (@log){
	    my $line= shift @log;
	    $line=~s/^\s+//;
	    last if $line eq undef;
	    my @line = split /\s+/, $line;
	    $NumAtom{$line[0]}++;
    }
    my $ShortLevel = (split/\./, $Mol)[0];
    $Mol=~s/^$ShortLevel\.//;
    $Mol=~s/\.log$//;
    return ($ShortLevel, $Mol, %NumAtom);
}


sub ReadEnthalpyLib{
    my $LibPath = shift;
    my $Level = shift;
    my %EnthalpyDic;
    my $csv = $LibPath.$Level.".Enthalpy.csv";
    open TAB, "< $csv" or die "Error for $csv missing!!!\n";
    my @tab = <TAB>;
    close TAB;
    shift @tab;
    for my $line (@tab){
        $line=~s/\s+$//;
        my @line = split /\,/, $line;
        $EnthalpyDic{$line[0]} = $line[2];
    }
    return %EnthalpyDic;
}


sub ChkMissingFrag{
    my $FragDir = shift;
    my $Prefix = shift;
    my @MissSmi;
    my %SmiDone;
    $SmiDone{$_} = 1 for @_;
    open PROD, "< $FragDir$Prefix.prod" or die "Error for $Prefix.prod missing!!!\n";
    open REAC, "< $FragDir$Prefix.reac" or die "Error for $Prefix.reac missing!!!\n";
    @prod = <PROD>;
    @reac = <REAC>;
    @frag = (@prod,@reac);
    close PROD;
    close REAC;
    for my $smi (@frag){
        $smi=~s/\s+$//;
        next if $SmiDone{$smi};
        push @MissSmi, $smi;
    }
    return @MissSmi;
}


sub GetSumEnthalpy{
    (my $file, my %Lib) = @_;
    my $SumEnthalpy = 0;
    open TMP, "< $file" or die "GetEnthalpy Err: $file missing!\n";
    my @tmp = <TMP>;
    close TMP;
    for $smi (@tmp){
        $smi=~s/\s+$//;
        $SumEnthalpy += $Lib{$smi};
    }
    return $SumEnthalpy;
}


sub CalcG4EOF{
    my %AtomEOF=(
        'C'=>0.27296900056,
        'H'=>0.0830203899,
        'O'=>0.0949038425,
        'N'=>0.18004192466,
        'F'=>0.0300857026,
        'Cl'=>0.0463454652
    );
    my %AtomEnthalpy=(
        'N'=>-54.571306,
        'O'=>-75.043141,
        'C'=>-37.831808,
        'H'=>-0.499060
    );
    (my $Enthalpy, my %NumAtom) = @_;
    my $EOF = $Enthalpy;
    for my $Atom(keys %NumAtom){
        $EOF += $NumAtom{$Atom}*($AtomEOF{$Atom} - $AtomEnthalpy{$Atom});
    }
    return $EOF;
}