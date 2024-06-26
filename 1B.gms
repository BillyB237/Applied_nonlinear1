*SF2822
*Solution of Task 1

Sets
    t hour /1*24/
    s station /1,2/
    i item /k,a,b,c,V0,vw,g,l/
    j other item /Vmax,Spmax,Umax,Pmax,Changemax/
;
ALIAS(t,tt);

Table TV(s,i)  table of parameter values
            k       a       b       c       V0         vw       g          l
1           4.0    0.8    0.01  -0.0005     1000000    0.11     3.2        2
2           5.0    1.1    0.02  -0.0006     10000      0.09     5.5     12.375;

Table maxval(s,j)  table of max values
    Vmax        Spmax      Umax         Pmax     changemax
1   1500000      50         20          100          0.25
2   180000       50         30          100          0.25
;


Parameters
    demand(t) demand at different hours
    /1*3    0
     4     40
     5     60
     6     70
     7     80
     8     100
     9      90
     10*12  50
     13*15  30
     16     40
     17     100
     18     120
     19     80
     20     60
     21*22  40
     23     20
     24     10/
     
    c1(t) Price to purchase MWh at different hours
    /1*4 44
     5*7 50
     8*24 44/
    
    c2(t) Price to sell MWh at different hours
    /1*4 39
     5*7 45
     8*24 39/
     
    inflow(s) natural inflow of water to each dam - excluding passing from upper station to lower
    /1 3
     2 2/
;
Variable
    C total cost
    eta(t,s) eta function
*    u_hour(t,s)  'flow per hour';

;

Positive variables
    u(t,s)  usable outflow from station s by time t
    spill(t,s) spillage from station s by time t
    V(t,s) Volume in basin of station s at time t
    b(t) MWh bought at time t
    x(t) MWh sold at time t
    p(t,s)

;

Equations
    COST total cost
    PowProd(t,s)  power produced
    etaconstants(t,s) calculation
    sat_demand(t) Ensures demand is satisfied
    basin(t,s) Volume in basin 1 at time t
    basin2(t) Volume in basin 2 at time t


    
    basin_initial(t,s) Volume in basin s  at time 0
    
    max_turbine maximum constraints for certain variables
    max_basin
    max_spill
    max_power(t,s)
    
    max_increase(t,s)
    max_decrease(t,s)
    totb(t)
    totx(t)

;

PowProd(t,s).. p(t,s) =E=  TV(s,"k")* u(t,s)*eta(t,s);
etaconstants(t,s) .. eta(t,s) =E= TV(s,"a") + TV(s,"b") * (u(t,s)) + TV(s,"c") * (u(t,s))**2;

sat_demand(t) .. sum(s,p(t,s))+b(t)-x(t) =e= demand(t);


basin(t,s)    .. V(t+1,"1") =e= V(t,"1") +(- u(t,"1") - spill(t,"1") + inflow("1"))*3600;

basin2(t)     .. V(t+1,"2") =e= V(t,"2") +(- u(t,"2") - spill(t,"2") + inflow("2")
                        + 0.6*u(t-3,"1")+0.6*spill(t-3,"1")+ 0.4*u(t-2,"1")+0.4*spill(t-2,"1"))*3600;

basin_initial(t,s)$(ord(t) =0).. V(t,s) =e= TV(s,"V0");

max_turbine(t,s) .. u(t,s) =l= maxval(s,"Umax"); 
max_basin(t,s) .. V(t,s) =l= maxval(s,"Vmax");
max_spill(t,s) .. spill(t,s) =l= maxval(s,"Spmax");
max_power(t,s) .. p(t,s) =l= maxval(s,"Pmax");

*This should not be chaged with 3600
max_increase(t,s)$(ord(t)>1) .. u(t,s) =l= u(t-1,s) + maxval(s,"changemax")*maxval(s,"Umax");
max_decrease(t,s)$(ord(t)>1) .. u(t,s) =g= u(t-1,s) - maxval(s,"changemax")*maxval(s,"Umax");

totb(t) .. b(t) =l= 100;

totx(t) .. x(t) =l= 100;


COST .. C =E= sum(t, c1(t)*b(t))- sum(t,x(t)*c2(t))- sum(s, TV(s,"vw")*V("24",s));

option nlp = conopt4;  
* Define the model
Model myModel2 /all/;

* Set CONOPT 4 as the solver for NLP problems
* Solve the model using Nonlinear Programming (NLP) minimizing the objective variable C
Solve myModel2 using NLP minimizing C;

* Display results for variable C and control variables u and others
display C.L, u.L, x.L, p.L, V.L, b.L;