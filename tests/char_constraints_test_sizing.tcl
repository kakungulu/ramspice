constrain {
    Vgs  0          3.2            6
    Vds  0          3.2            6
    L    180e-9     900e-8         6
    WbyL 1          500            4
    temp -40        120            4
}
constrain {
        Vgs  0          3.2            6
        Vds  0          3.2            6
	Vbs  -3.2        0              3
        L    180e-9     900e-8         6
        WbyL 1          500            4
        temp -40        125            2
}
constrain {
        Vgs  0          2.4            1
        Vds  0          2.4            1
	Vbs  -0.9       0              1
}
set ::fork_limit 4

