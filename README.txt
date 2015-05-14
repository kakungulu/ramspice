RAMSpice "Elgon" build
======================

    Setup
    =====
       First step:
       % source setup
       % echo $RAMSPICE
       make sure it is showing the current directory
    Compiling
    =========
       Three compilation targets supported:
          % comp
	  look for: bin/ramspice-*
       Object files are stored under object_file-* directories. 
       Don't remove those as they provide the "makey" feature of
       incremental compilation.
    Characterizing
    ==============
        1. Convert Spectre .scs file to SPICE model:
	    % cd $RAMSPICE/Spectre/40nm
	    % $RAMSPICE/rf2tcl.tcl -input crn40lp_1d8_v1d2.scs
	2. Run characterizing loop
    Version control
    ===============
        1. Check in changes
            % git commit -a -m "What was changed"
            % git push
	2. Check out changes
	    % git pull
	    
    Features
    ========
       1. Tcl Language Front-End
       2. Tcl vector mining
       3. cTree hierarchical database
       4. Lookup Tables (LUT) for STA-like decision making.
       5. PAT - Pareto front automated storage and retrieval
       6. POLY, FUNC, GAMMA - Virtual machine routine structures that are faster than Tcl, more flexible than C
       
    

