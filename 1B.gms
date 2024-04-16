* Solution of Task 1

Sets
    s station /1,2/
    t timesteps /1*24/
    i item /k,a,b,c,V0,vw/
    j other item /Vmax,Spmax,Umax,Pmax,Changemax/
;

Table TV(s,i)  table of parameter values
    k      a     b       c       V0          vw
1  4.0    0.8    0.01  -0.0005   1000000    0.11
2  5.0    1.1    0.02  -0.0006   10000      0.09;

Table maxval(s,j)  table of max values
    Vmax        Spmax       Umax        Pmax        changemax
1   1500000       18000     72000     100           18000
2   180000        18000     108000     100          21600
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
    /1 10800
     2 7200/
     
;
  
Variable
    C total cost
    eta(t,s) eta function

;

Positive variables
    u(t,s)  usable outflow from station s by time t
    spill(t,s) spillage from station s by time t
    V(t,s) Volume in basin of station s at time t
    b(t) MWh bought at time t
    p(t,s)
;

Equations
    COST total cost
    PowProd(t,s)  power produced
    etaconstants(t,s) calculation
    sat_demand(t) Ensures demand is satisfied
    basin1(t,s) Volume in basin at time t
    basin1_initial(t,s) Volume in basin at time t
    
    max_turbine maximum constraints for certain variables
    max_basin
    max_spill
    max_power
    
    max_increase(t,s)
    max_decrease(t,s)
    totP(t)
    totb(t)

   
;

etaconstants(t,s) .. eta(t,s) =E= TV(s,"a")+TV(s,"b")*u(t,s)+ TV(s,"c")*u(t,s)**2;
PowProd(t,s).. p(t,s) =E= TV(s,"k")*eta(t,s)*u(t,s)*3600;

sat_demand(t) .. demand(t) =E=  sum(s,p(t,s))+b(t);

basin1(t,s)$(ord(t) > 1).. V(t,s) =e= V(t-1,s) - u(t,s)*3600 - spill(t-1,s)*3600 + inflow(s);
basin1_initial(t,s)$(ord(t) = 1).. V(t,s) =e= TV(s,"V0");


max_turbine(t,s) .. u(t,s) =l= maxval(s,"Umax");
max_basin(t,s) .. V(t,s) =l= maxval(s,"Vmax");
max_spill(t,s) .. spill(t,s) =l= maxval(s,"Spmax");
max_power(t,s) .. p(t,s) =l= maxval(s,"Pmax");

max_increase(t,s)$(ord(t)>1) .. u(t,s) =l= u(t-1,s) + maxval(s,"changemax");
max_decrease(t,s)$(ord(t)>1) .. u(t,s) =g= u(t-1,s) - maxval(s,"changemax");

totP(t) .. sum(s, P(t,s)) =l= 100;
totb(t) .. b(t) =l= 100;


COST .. C =E= SUM(t, c1(t)*b(t)) - SUM((t,s), p(t,s)*c2(t)) - SUM(s, TV(s,"vw")*V("24",s));


Model myModel /all/;
Solve myModel using NLP minimizing C;
display C.L, u.L;