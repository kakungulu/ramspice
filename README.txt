RAMSpice "Mengo" build
======================

    Compiling
    =========
       Two compilation targets supported:
       1. Single Precision: 
          % compile.tcl -sp
	  look for: ramspice_sp
       2. Double Precision:
          % compile.tcl
	  look for: ramspice
       Object files are stored under object_file_sp and object_files directories
       respectively. Don't remove those as they provide the "makey" feature of
       incremental compilation.
       
    Version control
    ===============
       Due to the small size of the project and the need to migrate it accross
       new platforms frequently, I decided not to bother with git or other sophisticated
       incremental version control system. The repository contains a simple Tcl script
       called tag.tcl. Run it and then look in your home directory for a gzip'ed
       file (~12MB) with the host and tagging time in its name. The file is a
       compressed Tcl script in itself. Uncompressing the file and running it
       recreates all the files needed for restoring the version.
       
    Features
    ========
       1. Tcl Language Front-End
       2. Tcl vector mining
       3. cTree hierarchical database
       4. Lookup Tables (LUT) for STA-like decision making.
       5. Berkeley DB framework
    

