@ . add string test_array
@ test_array add array 4,4
::spice::array_set_legend test_array 0 0 1.2
::spice::array_set_legend test_array 0 1 1.3
::spice::array_set_legend test_array 0 2 1.4
::spice::array_set_legend test_array 0 3 1.5
::spice::array_set_legend test_array 1 0 1.2
::spice::array_set_legend test_array 1 1 1.3
::spice::array_set_legend test_array 1 2 1.4
::spice::array_set_legend test_array 1 3 1.5
@  test_array(0,0) = 3.2
@  test_array(0,1) = 5.6
@  test_array(0,2) = -2
@  test_array(0,3) = 0
@  test_array(1,0) = 31.2
@  test_array(1,1) = 5.61
@  test_array(1,2) = -21
@  test_array(1,3) = 100
@  test_array(3,0) = 3.2
@  test_array(3,1) = 5.6
@  test_array(3,2) = -2
@  test_array(3,3) = 0
@  test_array(2,0) = 31.2
@  test_array(2,1) = 5.61
@  test_array(2,2) = -21
@  test_array(2,3) = 100
array_save test_array array.db

@ . add string appended_array
@ appended_array add array 4,4
::spice::array_set_legend appended_array 0 0 1.2
::spice::array_set_legend appended_array 0 1 1.3
::spice::array_set_legend appended_array 0 2 1.4
::spice::array_set_legend appended_array 0 3 1.5
::spice::array_set_legend appended_array 1 0 1.2
::spice::array_set_legend appended_array 1 1 1.3
::spice::array_set_legend appended_array 1 2 1.4
::spice::array_set_legend appended_array 1 3 1.5
@  appended_array(0,0) = 73.2
@  appended_array(0,1) = 75.6
@  appended_array(0,2) = -72
@  appended_array(0,3) = 0
@  appended_array(1,0) = 731.2
@  appended_array(1,1) = 75.61
@  appended_array(1,2) = -721
@  appended_array(1,3) = 7100
@  appended_array(3,0) = 73.2
@  appended_array(3,1) = 75.6
@  appended_array(3,2) = -72
@  appended_array(3,3) = 70
@  appended_array(2,0) = 731.2
@  appended_array(2,1) = 75.61
@  appended_array(2,2) = -7271
@  appended_array(2,3) = 7100
array_save appended_array array.db append

