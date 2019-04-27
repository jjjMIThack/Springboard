/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM country_club.Facilities
WHERE membercost > 0.0

/* Q2: How many facilities do not charge a fee to members? */

SELECT 
	COUNT(membercost)
FROM 
	country_club.Facilities
WHERE 
	country_club.membercost == 0.0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
	facid,
	name,
	membercost,
	monthlymaintenance
FROM 
	country_club.Facilities
WHERE
	 membercost > 0.0 AND 
	 membercost < 0.2*monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT 
	*
FROM 
	country_club.Facilities
WHERE 
	facid IN (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 
	CASE WHEN monthlymaintenance > 1000 THEN 'expensive' ELSE 	'cheap' END AS label,
       name,
       monthlymaintenance
FROM 
	country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 
	firstname,
 	surname
FROM 
	country_club.Members

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 
	facility.name, 
	CONCAT(member.firstname,'	',member.surname)
FROM 
	country_club.Bookings book
LEFT OUTER JOIN 
	country_club.Facilities facility
ON book.facid = facility.facid
LEFT OUTER JOIN 
	country_club.Members member
ON 
	book.memid = member.memid
WHERE 
	facility.name LIKE '%tennis court%'
ORDER BY 
	member.surname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
	facility.name, 
	CONCAT(member.firstname, ' 	',member.surname),
	(CASE WHEN member.surname = 'GUEST' THEN facility.guestcost*book.slots ELSE facility.membercost*book.slots END) AS cost
FROM 
	country_club.Bookings book
LEFT OUTER JOIN 
	country_club.Facilities facility
ON book.facid = facility.facid
LEFT OUTER JOIN 
	country_club.Members member
ON book.memid = member.memid
WHERE
	 book.starttime LIKE '%2012-09-14%' AND 
((member.surname = 'GUEST' AND facility.guestcost*book.slots > 30)
 OR (member.surname != 'GUEST' AND facility.membercost*book.slots > 30))
GROUP BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT 
	fname, 
	CONCAT( s2.firstname, ' 	', s2.surname ), 
	s2.cost
FROM (SELECT (CASE WHEN member.surname = 'GUEST' THEN 	facility.guestcost * book.slots ELSE facility.membercost *book.slots END) AS cost, 
		member.surname AS surname, 
		member.firstname AS firstname, 	
		facility.name AS fname,
		book.starttime booktime
	FROM country_club.Bookings book
	LEFT OUTER JOIN 
		country_club.Facilities facility 
	ON book.facid = facility.facid
	LEFT OUTER JOIN 
		country_club.Members member 
	ON book.memid = member.memid
	) AS s2
WHERE s2.booktime LIKE '%2012-09-14%' AND (s2.cost > 30.0)
GROUP BY s2.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
	s3.facilityname,
	s3.revenue
FROM       
(SELECT
	s2.facname AS facilityname,
	SUM(s2.cost) AS revenue
FROM
	(SELECT
		facility.name AS facname,
		(CASE WHEN book.memid = 0 THEN 	facility.guestcost * book.slots ELSE facility.membercost *book.slots END) AS cost 
	FROM
		country_club.Bookings book
	LEFT OUTER JOIN 
		country_club.Facilities facility 
	ON book.facid = facility.facid
 ) as s2
GROUP BY
	s2.facname 

) AS s3 
WHERE 
	s3.revenue < 1000		