constrain {
        Vgs  0          2.2            6
        Vds  0          2.2            6
	Vbs  -2.2       0              4
	Lsize 1         128            6
	WbyL  1         513            9
}
set ::corner_list {ss tt ff fs sf}
set ::corner_list {mis}
set ::temp_list {125 27 -40 27 27} 
set ::temp_list {27} 
set ::accuracy 1e12
set ::res_factor 1
set ::fork_limit 4

