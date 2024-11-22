/*
   Query 1: Over how many years was the unemployment data collected?
   ================================================================
   This query uses the distinct() function to extract all unique years
   and calculates the total count.
*/

db.unemployment.distinct("Year").length;

/*
   Query 2: How many states were reported on in this dataset?
   ==========================================================
   This query uses the distinct() function to find all unique states
   and calculates the total count.
*/

db.unemployment.distinct("State").length;

/*
   Query 3: Count of all documents where the unemployment rate (Rate) is less than 1.0%
   ====================================================================================
*/

db.unemployment.find({ Rate: { $lt: 1.0 } }).count();

/*
   Query 4: Find all counties with an unemployment rate higher than 10%
   ====================================================================
   This query filters documents where Rate > 10 and returns the County,
   State, and Rate fields.
*/

db.unemployment.find(
  { Rate: { $gt: 10.0 } },
  { County: 1, State: 1, Rate: 1, _id: 0 }
);

/*
   Query 5: Calculate the average unemployment rate across all states.
   ===================================================================
   This query uses the $group stage to compute the average Rate.
*/

db.unemployment.aggregate([
  {
    $group: {
      _id: null,
      averageRate: { $avg: "$Rate" }
    }
  }
]);

/*
   Query 6: Find all counties with an unemployment rate between 5% and 8%.
   =======================================================================
   This query filters for rates between 5% and 8% and returns relevant fields.
*/

db.unemployment.find(
  { Rate: { $gte: 5.0, $lte: 8.0 } },
  { County: 1, State: 1, Rate: 1, _id: 0 }
);

/*
   Query 7: Find the state with the highest unemployment rate.
   ===========================================================
   This query sorts the data by Rate in descending order and limits the result to 1.
*/

db.unemployment.aggregate([
  { $sort: { Rate: -1 } },
  { $limit: 1 },
  { $project: { State: 1, Rate: 1, _id: 0 } }
]);

/*
   Query 8: Count how many counties have an unemployment rate above 5%.
   ====================================================================
   This query counts all documents where Rate > 5.
*/

db.unemployment.find({ Rate: { $gt: 5.0 } }).count();

/*
   Query 9: Calculate the average unemployment rate per state by year.
   ===================================================================
   This query groups data by both State and Year and computes the average Rate.
*/

db.unemployment.aggregate([
  {
    $group: {
      _id: { State: "$State", Year: "$Year" },
      averageRate: { $avg: "$Rate" }
    }
  },
  { $sort: { "_id.State": 1, "_id.Year": 1 } }
]);

/*
   Extra Credit 10: Total unemployment rate across all counties per state.
   =========================================================================
   This query groups data by State and computes the total unemployment rate
   by summing up the Rate values for all counties in each state.
*/

db.unemployment.aggregate([
  {
    $group: {
      _id: "$State",
      totalRate: { $sum: "$Rate" }
    }
  },
  { $sort: { totalRate: -1 } }
]);

/*
   Extra Credit 11: Total unemployment rate for states with data from 2015 onward.
   ================================================================================
   This query filters documents from 2015 onward, groups data by State, and computes
   the total unemployment rate by summing up the Rate values for all counties.
*/

db.unemployment.aggregate([
  { $match: { Year: { $gte: 2015 } } },
  {
    $group: {
      _id: "$State",
      totalRate: { $sum: "$Rate" }
    }
  },
  { $sort: { totalRate: -1 } }
]);
