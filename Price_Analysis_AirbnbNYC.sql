#Create Sub-tables based on rules of database normalization
USE AirbnbinNYC;

CREATE TABLE AirbnbinNYC.Property
AS (SELECT HouseID, ConstructionYear, Price, ServiceFee, LocationID, HostID, PolicyID
     FROM AirbnbinNYC.airbnb); 
     
CREATE TABLE AirbnbinNYC.PerformanceList
AS (SELECT HouseID, NumOfReviews, LastReview, ReviewsPerMonth, ReviewRateNumber, CalHostListingsCount
    FROM AirbnbinNYC.airbnb); 
    
CREATE TABLE AirbnbinNYC.AccomoPolicy
AS (SELECT PolicyID, InstantBookable, CancellationPolicy, MinNights, Availability365
   FROM AirbnbinNYC.airbnb);
   
CREATE TABLE AirbnbinNYC.HostList
AS (SELECT HostID, HostIdentityVerified
 FROM AirbnbinNYC.airbnb);
 
 CREATE TABLE AirbnbinNYC.NeighbourhoodList
 AS (SELECT Neighbourhood, NeighbourhoodGroup
  FROM AirbnbinNYC.airbnb);
  
CREATE TABLE AirbnbinNYC.LocationList
  AS (SELECT LocationID, Neighbourhood
   FROM AirbnbinNYC.airbnb);

#Select HouseID and LocationID based on the condition where house price is less than the average price. The list will be used for further analysis for Airbnb pricing. 
SELECT P.HouseID, P.LocationID
FROM (SELECT AVG(P.Price) AS avg_price
      FROM AirbnbinNYC.Property) AS AVGP, AirbnbinNYC.Property AS P 
WHERE P.Price < AVGP.avg_price;

#Select HouseID, Neighborhood, Price and ServiceFee to do further analysis regarding pricing based on the condition where the price is greater than the average price for the whole airbnb houses in NYC.
SELECT P.HouseID, L.Neighbourhood, P.Price, P.ServiceFee
FROM Property AS P
INNER JOIN LocationList AS L
ON P.LocationID = L.LocationID
WHERE Price > (SELECT AVG(Price) AS avg_price
			    FROM Property);

#Have a quick lookup from the Property table, and join with LocationList to select HouseID and Neighbourhood for further analysis.
WITH PList AS ( SELECT HouseID, Price, LocationID
           FROM Property),
     LList AS ( SELECT LocationID, Neighbourhood
           FROM LocationList)
SELECT PList.HouseID, LList.Neighbourhood
FROM PList
LEFT JOIN LList 
ON PList.LocationID=LList.LocationID;

#Select the average price in different neighborhoods according and compare with the price of the house. 
SELECT P.HouseID, 
       P.Price,
       AVG(Price) OVER (PARTITION BY L.Neighbourhood) AS avg_n_price
FROM Property AS P
LEFT JOIN LocationList AS L
ON P.LocationID = L.LocationID;
        