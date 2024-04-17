* Solution of Task 1

Sets
    s station /1,2/
    t timesteps /1*1440/
    i item /k,a,b,c,V0,vw/
    j other item /Vmax,Spmax,Umax,Pmax,Changemax/
;

Table TV(s,i)  table of parameter values
    k      a     b       c       V0          vw
1  4.0    0.8    0.01  -0.0005   1000000    0.11
2  5.0    1.1    0.02  -0.0006   10000      0.09;

Table maxval(s,j)  table of max values
    Vmax        Spmax      Umax      Pmax        changemax
1   1500000       3000     1200      100          300
2   180000        3000     1800      100          450
;

Parameters
    demand(t) demand at different time 
    /1*180        0
     181*240     40
     241*300     60
     301*360     70
     361*420     80
     421*480     100
     481*540      90
     541*720      50
     721*900      30
     901*960      40
     961*1020     100
     1021*1080     120
     1081*1140     80
     1141*1200     60
     1201*1320     40
     1321*1380     20
     1381*1440     10/
     
    c1(t) Price to purchase MWh at different times
    /1*240 44
     241*420 50
     421*1440 44/
    
    c2(t) Price to sell MWh at different times
    /1*240 39
     241*420 45
     421*1440 39/
     
    inflow(s) natural inflow of water to each dam - excluding passing from upper station to lower
    /1 180
     2 120/
     
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
    basin1(t) Volume in basin 1 at time t
    basin2(t) Volume in basin 2 at time t
    basin2_initial(t)

    basin_initial(t,s) Volume in basin s  at time 0
    
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
PowProd(t,s).. p(t,s) =E= TV(s,"k")*eta(t,s)*u(t,s);

sat_demand(t) .. demand(t)*60 =E=  sum(s,p(t,s))+b(t)/60;

basin1(t)$(ord(t) > 1).. V(t,"1") =e= V(t-1,"1") - u(t,"1") - spill(t-1,"1") + inflow("1");
basin2(t)$(ord(t) >= 152).. V(t,"2") =e= V(t-1,"2") - u(t,"2") - spill(t-1,"2") + inflow("2") + u(t-152,"1")+spill(t-152,"1");

basin2_initial(t)$(ord(t) < 152).. V(t,"2") =e= V(t-1,"2") - u(t,"2") - spill(t-1,"2") + inflow("2");

basin_initial(t,s)$(ord(t) = 1).. V(t,s) =e= TV(s,"V0");


max_turbine(t,s) .. u(t,s) =l= maxval(s,"Umax");
max_basin(t,s) .. V(t,s) =l= maxval(s,"Vmax");
max_spill(t,s) .. spill(t,s) =l= maxval(s,"Spmax");
max_power(t,s) .. p(t,s) =l= maxval(s,"Pmax");

max_increase(t,s)$(ord(t)>1) .. u(t,s) =l= u(t-1,s) + maxval(s,"changemax");
max_decrease(t,s)$(ord(t)>1) .. u(t,s) =g= u(t-1,s) - maxval(s,"changemax");

totP(t) .. sum(s, P(t,s)) =l= 100;
totb(t) .. b(t) =l= 100;


COST .. C =E= SUM(t, c1(t)*b(t)*60) - SUM((t,s), p(t,s)*c2(t)*60) - SUM(s, TV(s,"vw")*V("24",s));


Model myModel /all/;
Solve myModel using NLP minimizing C;
display C.L, u.L;