-- Uneven workloads

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q5;

-- You must not change this table definition.
CREATE TABLE q5 (
	assignment_id integer,
	username varchar(25), 
	num_assigned integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Find the number of groups a TA assigned to for each assignment
CREATE VIEW Shoudhave as 
    select AssignmentGroup.assignment_id as assignment_id, username, count(AssignmentGroup.group_id) as num
    from AssignmentGroup, Grader
    where AssignmentGroup.group_id = Grader.group_id
    group by AssignmentGroup.assignment_id, username;

-- Find those assignment range > 10
CREATE VIEW Greater as 
    select a.assignment_id as assignment_id, a.username as username, a.num as num_assigned
    from Shoudhave a, Shoudhave b 
    where a.assignment_id = b.assignment_id and a.username <> b.username 
        and ((a.num - b.num) > 10 or (a.num - b.num) < -10);

-- Find the assignment_id, username, and number of group TA assigned,for those assignment_id range > 10
CREATE VIEW Reportta as 
    select assignment_id, username, num
    from Greater NATURAL JOIN Shoudhave;

-- Final answer.
INSERT INTO q5 (select * from Reportta);
	-- put a final query here so that its results will go into the table.