array set ::bin {p,5,wmin 1.2e-6 n,2,lmin 1.2e-6 p,15,wmin 2.2e-7 p,7,lmax 1.2e-6 n,15,wmax 5e-7 p,5,wmax 1e-5 n,2,lmax 1e-5 p,15,wmax 5e-7 n,14,lmin 1.2e-6 p,4,lmin 1.8e-7 n,12,wmin 5e-7 p,14,lmin 1.2e-6 p,2,wmin 1e-5 n,14,lmax 1e-5 p,12,wmin 5e-7 p,4,lmax 5e-7 n,12,wmax 1.2e-6 p,14,lmax 1e-5 p,2,wmax 0.000900001 p,12,wmax 1.2e-6 n,11,lmin 5e-7 p,1,lmin 1e-5 n,8,wmin 1.2e-6 p,11,lmin 5e-7 n,11,lmax 1.2e-6 p,1,lmax 2.0001e-5 n,8,wmax 1e-5 p,11,lmax 1.2e-6 n,7,lmin 5e-7 n,5,wmin 1.2e-6 n,7,lmax 1.2e-6 n,5,wmax 1e-5 p,9,lmin 1e-5 p,7,wmin 1.2e-6 n,4,lmin 1.8e-7 p,9,lmax 2.0001e-5 n,2,wmin 1e-5 p,7,wmax 1e-5 n,4,lmax 5e-7 n,16,lmin 1.8e-7 n,2,wmax 0.000900001 p,6,lmin 1.2e-6 n,14,wmin 2.2e-7 p,16,lmin 1.8e-7 p,4,wmin 1e-5 n,16,lmax 5e-7 n,1,lmin 1e-5 p,14,wmin 2.2e-7 p,6,lmax 1e-5 n,14,wmax 5e-7 p,16,lmax 5e-7 p,4,wmax 0.000900001 n,1,lmax 2.0001e-5 p,14,wmax 5e-7 n,13,lmin 1e-5 p,3,lmin 5e-7 n,11,wmin 5e-7 p,13,lmin 1e-5 p,1,wmin 1e-5 n,13,lmax 2.0001e-5 p,11,wmin 5e-7 p,3,lmax 1.2e-6 n,11,wmax 1.2e-6 p,13,lmax 2.0001e-5 p,1,wmax 0.000900001 p,11,wmax 1.2e-6 n,9,lmin 1e-5 n,10,lmin 1.2e-6 n,7,wmin 1.2e-6 p,10,lmin 1.2e-6 n,9,lmax 2.0001e-5 n,10,lmax 1e-5 n,7,wmax 1e-5 p,10,lmax 1e-5 p,9,wmin 5e-7 n,6,lmin 1.2e-6 n,4,wmin 1e-5 p,9,wmax 1.2e-6 n,6,lmax 1e-5 n,4,wmax 0.000900001 p,8,lmin 1.8e-7 n,16,wmin 2.2e-7 p,6,wmin 1.2e-6 n,3,lmin 5e-7 p,16,wmin 2.2e-7 p,8,lmax 5e-7 n,16,wmax 5e-7 n,1,wmin 1e-5 p,6,wmax 1e-5 n,3,lmax 1.2e-6 p,16,wmax 5e-7 n,15,lmin 5e-7 n,1,wmax 0.000900001 p,5,lmin 1e-5 n,13,wmin 2.2e-7 p,15,lmin 5e-7 p,3,wmin 1e-5 n,15,lmax 1.2e-6 p,13,wmin 2.2e-7 p,5,lmax 2.0001e-5 n,13,wmax 5e-7 p,15,lmax 1.2e-6 p,3,wmax 0.000900001 p,13,wmax 5e-7 n,12,lmin 1.8e-7 p,2,lmin 1.2e-6 n,9,wmin 5e-7 n,10,wmin 5e-7 p,12,lmin 1.8e-7 n,12,lmax 5e-7 p,10,wmin 5e-7 p,2,lmax 1e-5 n,9,wmax 1.2e-6 n,10,wmax 1.2e-6 p,12,lmax 5e-7 p,10,wmax 1.2e-6 n,8,lmin 1.8e-7 n,6,wmin 1.2e-6 n,8,lmax 5e-7 n,6,wmax 1e-5 p,8,wmin 1.2e-6 n,5,lmin 1e-5 n,3,wmin 1e-5 p,8,wmax 1e-5 n,5,lmax 2.0001e-5 n,3,wmax 0.000900001 p,7,lmin 5e-7 n,15,wmin 2.2e-7}
set ::global_nlmin 1.8e-7
set ::global_nlmax 2.0001e-5
set ::global_nwmin 2.2e-7
set ::global_nwmax 0.000900001
set ::global_plmin 1.8e-7
set ::global_plmax 2.0001e-5
set ::global_pwmin 2.2e-7
set ::global_pwmax 0.000900001
set ::bsim_version 3v32
set lvalues {}
set wvalues {}
foreach key [array names ::bin n,*,lmin] {
    if {[lsearch $lvalues $::bin($key)]==-1} {
        lappend lvalues $::bin($key)
    }
}
foreach key [array names ::bin n,*,lmax] {
    if {[lsearch $lvalues $::bin($key)]==-1} {
        lappend lvalues $::bin($key)
    }
}
set wvalues {}
foreach key [array names ::bin n,*,wmin] {
    if {[lsearch $wvalues $::bin($key)]==-1} {
        lappend wvalues $::bin($key)
    }
}
foreach key [array names ::bin n,*,lmax] {
    if {[lsearch $wvalues $::bin($key)]==-1} {
        lappend wvalues $::bin($key)
    }
}
default opt(topv) 1.8
@ param/Spacing = 0.44e-6

@ param/mismatch/a = 3.37744475063080368
@ param/mismatch/b = 0.00146235833087048301
@ param/mismatch/c = 0.00730304496601069614
@ param/mismatch/d = 0.0652774379656948106
@ param/mismatch/e = 0.687501350978649476
@ param/mismatch/f = -2.41641147871096813
@ param/mismatch/A = -0.632200774027036913
@ param/mismatch/B = 0.000573503072238805883
@ param/mismatch/C = -0.013671975393906063
set ::VOS_FORMULA {
    float x = property_Area;
    float y = isize;
    float a,b,c,d,e,f,g,h,i,j,k;
    if((x >=0) `` (y <= 60)) {
    	    //Date= Feb 21, 2012
    	    //Time= 11:11:46 AM
    	    //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_gr_0__isize_lt_60.xls
    	    //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_gr_0__isize_lt_60.xls : (1)offset_std
    	    a = 12.8855796266630426;
    	    b = -5.41083764511328898;
    	    c = -1.30763085764638906;
    	    d = 0.313643695922134216;
    	    e = 0.093119070398655552;
    	    f = 0.000152253934602799006;
    	    g = 0.027558789121119705;
    	    h = -0.0908038658897388513;
    	    i = -0.00736092968454125981;
    	    j = 0.00997803516051362148;
    	    return (a+b*logf(x)+c*pow((logf(x)),2)+d*pow((logf(x)),3)+e*pow((logf(x)),4)+f*pow((logf(x)),5)+g*logf(y)+h*pow((logf(y)),2)+i*pow((logf(y)),3)+j*pow((logf(y)),4))/1000;
    } else if((x <= 0) `` (y <= 60)) {
    	    //Date= Feb 21, 2012
    	    //Time= 11:23:06 AM
    	    //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_lt_60.xls
    	    //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_lt_60.xls : (1)offset_std
    	    a = 2.93660485783974259;
    	    b = -0.332364084793881404;
    	    c = 0.00766917418689004997;
    	    d = 0.0815859439577785321;
    	    e = -0.0511853190713728586;
    	    f = 0.0146507924776217549;
    	    g = -0.00248296699178136492;
    	    return (expf(a+b*x+c*pow(x,2)+d*pow(y,(1.5))+e*pow(y,2)+f*pow(y,2)*logf(y)+g*pow(y,(2.5))))/1000;
    } else if((x > 0) `` (y > 60)) {
    	    //Date= Feb 21, 2012
    	    //Time= 11:29:50 AM
    	    //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_gr_0_isize_gr_60.xls
    	    //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_gr_0_isize_gr_60.xls : (1)offset_std
    	    a = 0.0245510804148098408;
    	    b = 0.00571642685094725414;
    	    c = -0.038594299737104845;
    	    d = -0.00293384210596431143;
    	    e = 0.0164401882567682581;
    	    return (1/(a+b*pow(x,(2.5))+c*expf(-x)+d*y+e*y/logf(y)))/1000;
    } else {
    	    //Date= Feb 21, 2012
    	    //Time= 11:34:55 AM
    	    //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_gr_60.xls
    	    //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_gr_60.xls : (1)offset_std
    	    a = 16.2036851911088104;
    	    b = 0.21279234971619464;
    	    c = -1.7053361877790996;
    	    d = -0.00746030946920476022;
    	    e = -0.118672118503179062;
    	    f = 0.0131583901472111854;
    	    g = -0.138292160061225562;
    	    h = 1.76686418477095332e-05;
    	    i = 0.000389109336629294047;
    	    j = -0.000674088087058916077;
    	    k = 0.00383260060449367847;
    	    return (((a+c*x+e*y+g*pow(x,2)+i*pow(y,2)+k*x*y)/(1+b*x+d*y+f*pow(x,2)+h*pow(y,2)+j*x*y))/1000);
    }
}

