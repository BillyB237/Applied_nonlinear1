* Solution of Task 1

Sets
    s station /1,2/
    t hour /1*24/
    i item /k,a,b,c,V0,vw/
    j other item /Vmax,Spmax,Fmax,Pmax,Changemax/
;

Table Values(s,i)  table of parameter values
    k      a     b       c       V0          vw
1  4.0    0.8    0.01  -0.0005   1000000    0.11
2  5.0    1.1    0.02  -0.0006   1000000    0.09;

Table Dam(s,j)  table of dam values
    Vmax        Spmax   Fmax    Pmax    changemax
1   1000000       50     20     100       0.25  
2   1.800000      50     30     100       0.25
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
     
    priceb(t) Price to purchase MWh at different hours
    /1*4 44
     5*7 50
     8*24 44/
    
    prices(t) Price to sell MWh at different hours
    /1*4 39
     5*7 45
     8*24 39/
     
    inflow(s) natural inflow of water to each dam - excluding passing from upper station to lower
    /1 3
     2 2/
;
  
Variable
    C total cost
;

Positive variables
    u(t,s)  usable outflow from station s by time t
    p(t,u,s) power generated at time t by waterflow u and by station s
    spill(t,s) spillage from station s by time t
    V(t,s) Volume in basin at time t in station s
    b(t) MWh bought at time t
    
    
;

Equations
    COST total cost
;

COST .. C =E= SUM(t, priceb(t)*b(t)) - SUM((t,s), p(t,u,s)*prices(t)) - SUM(s, T(s,6)*V(t,s));

Solve 1B using NLP maximizing C;
