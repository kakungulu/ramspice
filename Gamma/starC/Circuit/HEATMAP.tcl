*c "int i,j;"
*c "ClientData CD;"
*c "if ((argc!=15)&&(argc!=14)&&(argc!=13)) \{"
*c "    #Error: \"%s: usage: %s <x context> <minX> <maxX> <stepX> <y context> <minY> <maxY> <stepY> <z context> <pixel width> <pixel height> <pallet> [<pallet mode> [<pass threshold>]]\" argv[0] argv[0]"
*c "    return TCL_ERROR;"
*c "\}"
*c "    float *pX=(float *)&(create_context(argv[1]))->value.s;"
*c "    float *pY=(float *)&(create_context(argv[5]))->value.s;"
*c "    float *pZ=(float *)&(create_context(argv[7]))->value.s;"
foreach dim {X Y Z} argi {1 5 7} {
*c "    float *P$dim=NULL;"
    @ / foreach_child s1 {
        @ /$s1 foreach_child s2 {
            *c "if (strcmp(argv[$argi],\"${s1}:${s2}\")==0) P$dim=&(@${s1}:${s2});"
	}    
    }
    *c "if (P$dim==NULL) \{"
    *c "    #Error: \"%s: context %s is not available for heatmap generation.\" argv[0] argv[1]"
    *c "    return TCL_ERROR;"
    *c "\}"
    if {$dim=="Z"} continue
    foreach param {min max step} {
        incr argi
        *c "float $param$dim=atof(argv[$argi]);"
    }
}
*c "int width=(int)(maxX-minX)/stepX+1;"
*c "int height=(int)(maxY-minY)/stepY+1;"
*c "int ARGC;"
*c "char **ARGV;"
*c "Tcl_SplitList(interp,argv[12],&ARGC,&ARGV);"
*c "int *pal=(int *)malloc(sizeof(int)*ARGC);"
*c "for (i=0;i<ARGC;i++) pal[i]=atoi(ARGV[i]);"
*c "heatmap *hm=new_heatmap(width,height,atoi(argv[10]),atoi(argv[11]),pal,ARGC);"
*c "int mode=-1;"
*c "float th=0;"
*c "if (argc==13) mode=HM_TH_MODE_FLAT; else \{"
foreach mode {flat snap half} {
    *c "if (strcmp(argv[13],\"$mode\")==0) mode=HM_TH_MODE_[string toupper $mode];"
}
*c "\}"
*c "if (mode==-1) \{"
*c "	#Error: \"%s: pallet mode %s is not available for heatmap generation. Use flat, snap or half\" argv[0] argv[13]"
*c "	return TCL_ERROR;"
*c "\}"
*c "if ((mode!=HM_TH_MODE_FLAT)&&(argc!=15)) \{"
*c "	#Error: \"%s: pallet mode %s requires a threshold for passing specifications.\" argv[0] argv[13]"
*c "	return TCL_ERROR;"
*c "\} else th=atof(argv[14]);"
*c "float X,Y;"
*c "i=0;"
*c "for (X=minX;X<=maxX;X+=stepX) \{"
*c "    j=0;"
*c "    for (Y=minY;Y<=maxY;Y+=stepY) \{"
*c "        *PX=X;"
*c "        *PY=Y;"
*c "        tcl_gamma_${::opt(topology)}_op_cmd(CD,NULL,0,NULL);"
*c "        set_heatmap_pixel(hm,i,j,*PZ);"
*c "        j++;"
*c "    \}"
*c "    i++;"
*c "\}"
*c "heatmap_thresholds(hm,mode,th);"
*c "char *out_channel_name=Tcl_GetVar(interp,\"::HTML\",0);"
*c "FILE *HTML;"
*c "Tcl_GetOpenFile(interp,out_channel_name,1,0,&HTML);"
*c "plot_heatmap(hm,0,0,HTML);"




