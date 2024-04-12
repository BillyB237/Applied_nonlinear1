* Solution of Task 1

Sets
    s station /1,2/
    t seconds /0*86400/
    i item /k,a,b,c,V0,vw/
    j other item /Vmax,Spmax,Fmax,Pmax,Changemax/
;

Table TV(s,i)  table of parameter values
    k      a     b       c       V0          vw
1  4.0    0.8    0.01  -0.0005   1000000    0.11
2  5.0    1.1    0.02  -0.0006   1000000    0.09;

Table Dam(s,j)  table of dam values
    Vmax        Spmax   Fmax    Pmax    changemax
1   1000000       50     20     100       0.25  
2   1.800000      50     30     100       0.25
;

Parameters
    demand(t) demand at different seconds
    /0*10799  0
     14400    40
     18000    60
     21600    70
     25200    80
     28800    100
     32400    90
     36000*43199  50
     46800*54000  30
     57600    40
     61200    100
     64800    120
     68400    80
     72000    60
     75600*79200  40
     82800    20
     86400    10/     

    priceb(t) Price to purchase MWh at different seconds
    /0*14399  44
     18000*25199  50
     25200*86399  44/
    
    prices(t) Price to sell MWh at different seconds
    /0*14399  39
     18000*25199  45
     25200*86399  39/

    inflow(s) natural inflow of water to each dam - excluding passing from upper station to lower
    /1 3
     2 2/
;
  
Variable
    C total cost
;

Positive variables
    u(t,s)  usable outflow from station s by time t
    spill(t,s) spillage from station s by time t
    V(t,s) Volume in basin at time t in station s
    b(t) MWh bought at time t
    p(t,s)
    eta(t,s) eta function
;

Equations
    COST total cost
    PowProd(t,s)  power produced
    etaconstants(t,s) calculation
;

etaconstants(t,s) .. eta(t,s) =E= TV(s,"a")+TV(s,"b")*u(t,s)+ TV(s,"c")*u(t,s)**2;
PowProd(t,s).. p(t,s) =E= TV(s,"k")*eta(t,s)*u(t,s);


COST .. C =E= SUM(t, priceb(t)*b(t)) - SUM((t,s), p(t,s)*prices(t)) - SUM(s, TV(s,"vw")*V("24",s));

Model myModel /all/;
Solve myModel using NLP minimizing C;