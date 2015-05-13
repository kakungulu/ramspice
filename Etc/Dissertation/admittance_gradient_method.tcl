####   Common Characters
set ::MULT "&#215;"
set ::GVM "&#915;VM"

* Chapter Admittance Gradient Method
** Title Motivation
Body {
Gradient methods in optimization seek the fastest improving direction in the solution space. The methods for extracting a vector of improving given solution can be deterministic (e.g. derivation of a cost function) or stochastic (e.g. Hill Climbing).
Using gradient method for circuit sizing has been primarily of the stochastic variety, mainly because of the complexity of the equations and lack in confidence in sizing factors influence on performance properties. 
Hill Climbing method, for example, attempts to draw an improving direction from a random sample of direction and thus ratchet the circuit closer to a feasible solution. It cannot guarantee speed of convergance or convergance at all. 
This method, albeit potentially slow, is useful in obtaining a feasible solution for a given spec.
For the application of obtaining a large set of solutions that map the size/performance Pareto fronts, a faster method for improving a given circuit is necessary. The $::GVM needs to make a probable guess of a vector that points a circuit to a better value 
of a given property. The $::GVM compiler has an advantage of performing a symbolic modified nodal analysis (herein: MNA). The equations that translate down the compilation cascade into $::GVM instructions can be used to analyze the value of each property 
as well as the gradient of that property in the solution space. <br>
}
** Title Example Circuit
Body {
<svg height="250" width="150">
    <rect stroke="rgb(100, 200, 150)" stroke-width="1" fill="rgb(255, 255, 255)" height="250" width="150"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="0" x="0"></rect>
    <line transform="rotate(0 75 25)" stroke="rgb(0,0,0)" stroke-width="2" y2="50" x2="75" y1="10" x1="75"></line>
    <line transform="rotate(0 75 25)" stroke="rgb(0,0,0)" stroke-width="1" y2="25" x2="90" y1="25" x1="60"></line>
    <line transform="rotate(0 75 25)" stroke="rgb(0,0,0)" stroke-width="1" y2="10" x2="75" y1="25" x1="60"></line>
    <line transform="rotate(0 75 25)" stroke="rgb(0,0,0)" stroke-width="1" y2="25" x2="90" y1="10" x1="75"></line>
    <rect onclick="vdd(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="0" x="50"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="0" x="100"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="50" x="0"></rect>
    <circle fill-opacity="0.0" stroke="rgb(0,0,0)" fill="rgb(0,0,0)" stroke-width="1" r="15" cy="75" cx="75"></circle>
    <line transform="rotate(180 75 75)" stroke="rgb(0,0,0)" stroke-width="2" y2="60" x2="75" y1="50" x1="75"></line>
    <line transform="rotate(180 75 75)" stroke="rgb(0,0,0)" stroke-width="2" y2="100" x2="75" y1="90" x1="75"></line>
    <line transform="rotate(180 75 75)" stroke="rgb(0,0,0)" stroke-width="1" y2="85" x2="75" y1="65" x1="75"></line>
    <line transform="rotate(180 75 75)" stroke="rgb(0,0,0)" stroke-width="1" y2="75" x2="85" y1="75" x1="65"></line>
    <line transform="rotate(180 75 75)" stroke="rgb(0,0,0)" stroke-width="1" y2="65" x2="75" y1="75" x1="65"></line>
    <line transform="rotate(180 75 75)" stroke="rgb(0,0,0)" stroke-width="1" y2="75" x2="85" y1="65" x1="75"></line>
    <rect onclick="out(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="50" x="50"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="50" x="100"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="100" x="0"></rect>
    <line transform="rotate(270 75 125)" stroke="rgb(0,0,0)" stroke-width="2" y2="125" x2="100" y1="125" x1="50"></line>
    <line transform="rotate(270 75 125)" stroke="rgb(0,0,0)" stroke-width="2" y2="150" x2="75" y1="125" x1="75"></line>
    <circle fill-opacity="1.0" stroke="rgb(0,0,0)" fill="rgb(0,0,0)" stroke-width="1" r="4" cy="125" cx="75"></circle>
    <rect onclick="out(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="100" x="50"></rect>
    <line transform="rotate(90 125 125)" stroke="rgb(0,0,0)" stroke-width="2" y2="150" x2="125" y1="130" x1="125"></line>
    <circle fill-opacity="0.0" stroke="rgb(0,0,0)" fill="rgb(0,0,0)" stroke-width="1" r="5" cy="125" cx="125"></circle>
    <text transform="rotate(90 125 125)" font-weight="bold" fill="rgb(0,0,0)" y="118" x="110"></text>
    <rect onclick="out(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="100" x="100"></rect>
    <line transform="rotate(270 25 175)" stroke="rgb(0,0,0)" stroke-width="2" y2="200" x2="25" y1="180" x1="25"></line>
    <circle fill-opacity="0.0" stroke="rgb(0,0,0)" fill="rgb(0,0,0)" stroke-width="1" r="5" cy="175" cx="25"></circle>
    <text transform="rotate(270 25 175)" font-weight="bold" fill="rgb(0,0,0)" y="168" x="10"></text>
    <rect onclick="inx(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="150" x="0"></rect>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="2" y2="175" x2="85" y1="175" x1="100"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="165" x2="85" y1="175" x1="85"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="165" x2="65" y1="165" x1="85"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="165" x2="65" y1="175" x1="65"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="2" y2="175" x2="50" y1="175" x1="65"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="160" x2="65" y1="160" x1="85"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="2" y2="160" x2="75" y1="150" x1="75"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="170" x2="70" y1="175" x1="65"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="170" x2="60" y1="170" x1="70"></line>
    <line transform="rotate(270 75 175)" stroke="rgb(0,0,0)" stroke-width="1" y2="170" x2="60" y1="175" x1="65"></line>
    <rect onclick="n_ref(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="150" x="50"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="150" x="100"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="200" x="0"></rect>
    <line transform="rotate(0 75 225)" stroke="rgb(0,0,0)" stroke-width="2" y2="240" x2="75" y1="200" x1="75"></line>
    <line transform="rotate(0 75 225)" stroke="rgb(0,0,0)" stroke-width="1" y2="225" x2="90" y1="225" x1="60"></line>
    <line transform="rotate(0 75 225)" stroke="rgb(0,0,0)" stroke-width="1" y2="230" x2="85" y1="230" x1="65"></line>
    <line transform="rotate(0 75 225)" stroke="rgb(0,0,0)" stroke-width="1" y2="235" x2="80" y1="235" x1="70"></line>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="200" x="50"></rect>
    <rect onclick="(evt)" fill="rgb(160,255,160)" fill-opacity="0.1" height="50" width="50" y="200" x="100"></rect>
</svg><br>
A common-source nmos circuit has the following MNA matrix:
<table> <tr><td> 
<table class="matrix"> <tr>  <td> 0 </td> <td> 0 </td> <td> 0 </td> <td> 0 </td> <td> 1 </td>  </tr> <tr>  <td> gm<sub>M1</sub> </td> <td> go<sub>M1</sub> </td> <td> 0 </td> <td> 0 </td> <td> 0 </td> </tr> <tr> <td> 0 </td> <td> 0 </td> <td> 0 </td> <td> 1 </td> <td> 0 </td> </tr> <tr> <td> 0 </td> <td> 0 </td> <td> 1 </td> <td> 0 </td> <td> 0 </td> </tr> <tr>  <td> 1 </td> <td> 0 </td> <td> 0 </td> <td> 0 </td> <td> 0 </td> </tr> </table> 
</td> <td>
</td> <td>
</td> <td>
*
</td> <td>
</td> <td>
</td> <td>
<table class="matrix"> <tr>  <td> V<sub>IN</sub> </td> </tr> <tr>  <td> V<sub>OUT</sub></td> </tr> <tr>  <td> V<sub>DD</sub> </td> </tr> <tr> <td> 0 </td> </tr> <tr>  <td> 0 </td> </tr> </table> 
</td> <td>
</td> <td>
</td> <td>
=
</td> <td>
</td> <td>
</td> <td>
<table class="matrix"> <tr>  <td> 0 </td> </tr> <tr>  <td> I<sub>SOURCE</sub>-Id<sub>M1</sub> </td> </tr> <tr>  <td> 0 </td> </tr> <tr> <td> V<sub>DD</sub> </td> </tr> <tr>  <td> V<sub>IN</sub> </td> </tr> </table> 
</td></tr></table>
The equation $::GVM compiles to calculate V<sub>OUT</sub> operating point is:<br>
<table><tr><td>V<sub>OUT</sub></td><td>=</td><td><table class="fraction"> <tr><td>gm<sub>M1</sub>V<sub>IN</sub>+I<sub>SOURCE</sub>-Id<sub>M1</sub></td></tr><tr><td class="upper_line">-go<sub>M1</sub></td></tr></table></td></tr></table>
The DC Gain of the circuit is:<br>
<table><tr><td>A<sub>DC</sub></td><td>=</td><td><table class="fraction"> <tr><td>&#8706;V<sub>OUT</sub></td></tr><tr><td class="upper_line">&#8706;V<sub>IN</sub></td></tr></table></td><td>=</td><td>-</td><td><table class="fraction"> <tr><td>gm<sub>M1</sub></td></tr><tr><td class="upper_line">go<sub>M1</sub></td></tr></table></td></tr></table>
How can $::GVM increase the gain? <br>
In other words, how does A<sub>DC</sub> depend on the length and width of the M1 transistor?
<table><tr><td>
<table class="fraction"> <tr><td>&#8706;A<sub>DC</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table></td><td>=</td><td>
<table class="fraction"> <tr><td>&#8706;A<sub>DC</sub></td></tr><tr><td class="upper_line">&#8706;gm<sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;gm<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table></td><td>+</td><td>
<table class="fraction"> <tr><td>&#8706;A<sub>DC</sub></td></tr><tr><td class="upper_line">&#8706;go<sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;go<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table></td><td>=</td><td>
<table class="fraction"> <tr><td>-1</td></tr><tr><td class="upper_line">go<sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;gm<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table></td><td>+</td><td>
<table class="fraction"> <tr><td>gm<sub>M1</sub></td></tr><tr><td class="upper_line">go<sup>2</sup><sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;go<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table>
</td></tr></table>
Similarly:<br>
<table><tr><td>
<table class="fraction"> <tr><td>&#8706;A<sub>DC</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table></td><td>=</td><td>
<table class="fraction"> <tr><td>&#8706;A<sub>DC</sub></td></tr><tr><td class="upper_line">&#8706;gm<sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;gm<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table></td><td>+</td><td>
<table class="fraction"> <tr><td>&#8706;A<sub>DC</sub></td></tr><tr><td class="upper_line">&#8706;go<sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;go<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table></td><td>=</td><td>
<table class="fraction"> <tr><td>-1</td></tr><tr><td class="upper_line">go<sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;gm<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table></td><td>+</td><td>
<table class="fraction"> <tr><td>gm<sub>M1</sub></td></tr><tr><td class="upper_line">go<sup>2</sup><sub>M1</sub></td></tr></table></td><td>*</td><td>
<table class="fraction"> <tr><td>&#8706;go<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table>
</td></tr></table>
gm and go are obtained from the nmos LUT look up and interpolation.<br> <br><br><br><br>The derivatives 
<table><tr><td>
<table class="fraction"> <tr><td>&#8706;gm<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table>
</td><td>,</td><td>
<table class="fraction"> <tr><td>&#8706;go<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;W<sub>M1</sub></td></tr></table>
</td><td>,</td><td>
<table class="fraction"> <tr><td>&#8706;gm<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table>
</td><td> and </td><td>
<table class="fraction"> <tr><td>&#8706;go<sub>M1</sub></td></tr><tr><td class="upper_line">&#8706;L<sub>M1</sub></td></tr></table>
</td><td></table>
are also looked up in a modified interpolation algorithm:<br>
<img src="file://$::env(RAMSPICE)/Dissertation/GradInterpolation.jpg" height="300" width="300"><br>
The modified Lagrange algorithm weighs every dimension as before, but for each dimension it forks a side interpolation sequence that begins with subtracting the two sides of the hypercube instead of weighing them. 
The result is the original interpolated value in addition to the derivative per dimension. <br>
There are some fundamental flaws to this approach:<br>
1. The actual gradient of the circuit's property (A<sub>DC</sub> in the example) contains more components than the admittance values direct L and W derivatives. 
In a multi-transistor circuit, gm and go values of one transistor may have some dependence on the L and W of another transistor. 
The reason for that is that a change in the geometry of the other transistor may change the operating point of the first one and thus change the latter's gm and go.
This method in only admittance-gradient based, rather than full-gradient based, which requires more calculations.<br>
2. The Newton Raphson method can't be applied to the found gradient, because the conditions of function definition, diferentiability and smoothness are not met in the global sense of the circuit's behaviour. 
Stepping with a full or even too large fraction of the NR step can easily throw the some of the transistors to the cut-off region, where derivatives are not useful for further steps.<br>
3. Only properties that can be estimated statically and using algebraic methods of pre-compiling and pre-deriving rational functions can be measured and improved. THD, for instance, is outside of the scope of the $::GVM Pareto mapper.<br> 
However, the method has two benefits for the $::GVM Pareto application:<br>
1. It generates an improvement step without the need to fully calculate multiple circuits' operating points and performance properties. 
This method of using only LUT's outputs and few pre-compiled equations is magnitudes faster than using SPICE simulations and scripts tailored to measure circuit performance properties.<br>
2. Although imperfect, the calculated step is likely to improve the performance of the circuit. The Pareto mechanism is designed to filter out useless circuits, so an occasional degredation of performance (in case OP effects are two large to neglect) does not detract from the overall quality of results.
<font color=red>
<i><br> Produce: <br> 1. Rate of improving vs. degrading gradients calculated by AG <br> 2. Run time figures of AG steps vs. BSIM convergance <br> 3. A list of improveable properties</i><br>
Cite: <a href="http://delivery.acm.org/10.1145/250000/244551/p174-conn.pdf?ip=129.82.198.9&id=244551&acc=ACTIVE%20SERVICE&key=B63ACEF81C6334F5.43B80C8545818863.4D4702B0C3E38B35.4D4702B0C3E38B35&CFID=673527594&CFTOKEN=32236679&__acm__=1431379834_74e38a9ad05aa5de13d0dcd1b528d8d8">Optimization of custom MOS circuits by transistor sizing</a>

</font>
}



