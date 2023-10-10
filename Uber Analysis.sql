SELECT * FROM public."Assembly";

SELECT * FROM public."Payment";

SELECT * FROM public."Duration";

SELECT * FROM public."Trip_Details";

SELECT * FROM public."Trips";

--Checking for any duplicate values in Trip_Details
Select "tripID", count("tripID") FROM public."Trip_Details"
GROUP BY "tripID" HAVING count("tripID")>1;

--Total Drivers
Select count(distinct "DriverID") AS total_drivers FROM public."Trips";

--Total earnings in Trips = 751343
Select sum("Fare") AS Total_Earnings FROM public."Trips";

--Total searches overall = 2161
Select count("Searches") FROM public."Trip_Details";

--Total searches which got estimate fares = 1758
Select count("Searches_got_estimate") FROM public."Trip_Details"
WHERE "Searches_got_estimate"=1;

--Total searches for drivers after seeing the fare = 1455
Select count("Searches_for_quotes") FROM public."Trip_Details"
WHERE "Searches_for_quotes"=1;

--Total searches which actually showed for driver = 1277
Select count("Searches_got_quotes") FROM public."Trip_Details"
WHERE "Searches_got_quotes"=1;

--Total trips the driver cancelled = 1021
Select count("Driver_not_cancelled") FROM public."Trip_Details"
WHERE "Driver_not_cancelled"=0;

--Total OTP entered = 983
Select count("Otp_entered") FROM public."Trip_Details"
WHERE "Otp_entered"=1;

--Total rides that successfully ended = 983
Select count("End_ride") FROM public."Trip_Details"
WHERE "End_ride"=1;

--Average distance per trip
Select ROUND(avg("Distance"),2) FROM public."Trips";

--Avergae fare per trip
Select FLOOR(avg("Fare")) FROM public."Trips";

--Distance travelled
Select sum("Distance") FROM public."Trips";

--Most used payment method = 4 - credit card
Select a."Method" FROM public."Payment" a INNER JOIN

(Select "Fare_method", count("Fare_method") FROM public."Trips"
GROUP BY "Fare_method"
ORDER BY count("Fare_method") DESC
limit 1) b

ON a."ID" = b."Fare_method";


--By which means was the highest fare payment done - credit card(4) and cash(1)
Select a."Method", b."Fare_method", b."Fare" FROM public."Payment" a INNER JOIN

(Select * FROM public."Trips"
WHERE "Fare" = (Select max("Fare") FROM public."Trips")) b

ON a."ID" = b."Fare_method";


--Overall which payment method did the most transactions
Select a."Method", b."Fare_method", b."sum" FROM public."Payment" a INNER JOIN

(Select "Fare_method", sum("Fare") FROM public."Trips"
GROUP BY "Fare_method"
ORDER BY sum("Fare") DESC LIMIT 1) b

ON a."ID" = b."Fare_method";


--Which two locations had the most trips
Select a."Assembly", b."Loc_to", b."count" FROM public."Assembly" a INNER JOIN

(Select "Loc_to", count("Loc_to") FROM public."Trips"
GROUP BY "Loc_to"
ORDER BY count("Loc_to") DESC
LIMIT 2) b

ON a."ID" = b."Loc_to";


--Which pair of locations covered the most trips
Select * FROM

(Select *, dense_rank() over(ORDER BY trip DESC) AS rank
FROM
 
(Select "Loc_from", "Loc_to", count("TripID") AS trip FROM public."Trips"
GROUP BY ("Loc_from", "Loc_to")
ORDER BY count("TripID") DESC))

WHERE rank=1;


--Top 5 earning drivers
Select "DriverID", sum("Fare") FROM public."Trips"
GROUP BY "DriverID"
ORDER BY sum("Fare") DESC
LIMIT 5;


--Which hour duration has the most number of trips
Select * FROM

(Select *, dense_rank() over (ORDER BY count_durations DESC) AS rank
FROM
(Select a."Duration", b."Duration", b."count_durations" FROM public."Duration" a
INNER JOIN
(Select "Duration", count("TripID") AS count_durations FROM public."Trips"
GROUP BY "Duration") b
ON a."ID" = b."Duration"))

WHERE rank=1;


--Which driver customer pair had most orders
Select * FROM

(Select *, dense_rank() over (ORDER BY count_trips DESC) AS rank
FROM
(Select "DriverID", "CustID", count("TripID") as count_trips FROM public."Trips"
GROUP BY ("DriverID", "CustID")))

WHERE rank=1;


--Total searches_got_estimate to searches in trip_details
Select ROUND((sum("Searches_got_estimate")*100.0 / sum("Searches")), 2) 
FROM public."Trip_Details";


--Searches to end_rides rate
Select ROUND((sum("End_ride")*100.0 / sum("Searches")), 2) 
FROM public."Trip_Details";


--Which areas got highest trips in each duration
Select b."Duration", b."Loc_from", a."Assembly", b."cnt" FROM public."Assembly"
a INNER JOIN

(Select * FROM
(Select *, rank() OVER (partition by "Duration" ORDER BY cnt DESC) AS rank
FROM
(Select "Duration", "Loc_from", count("TripID") AS cnt FROM public."Trips"
GROUP BY ("Duration", "Loc_from")))
WHERE rank = 1) b

ON a."ID" = b."Loc_from";


