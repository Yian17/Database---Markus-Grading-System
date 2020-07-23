-- High coverage

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q7;

-- You must not change this table definition.
CREATE TABLE q7 (
	ta varchar(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Find all TA and instructor
CREATE VIEW graders as
    select username
    from MarkusUser
    where type = 'TA' or type = 'instructor';

-- Find TA who has been assigned to a group
CREATE VIEW subgraders as
    select username, group_id, assignment_id
    from Grader NATURAL JOIN AssignmentGroup;

-- Combine graders and subgraders
CREATE VIEW summarygraders as
    select graders.username as username, group_id, assignment_id
    from graders NATURAL JOIN subgraders;

-- Find graders who have mark all assignment
CREATE VIEW grader_marked_all_assign as
    select username
    from summarygraders
    group by username
    having count(distinct assignment_id) = (select count(distinct assignment_id)
                                             from Assignment);
-- Find TA have been assigned to grade every student
CREATE VIEW grader_marked_all_for_one as
    select username 
    from
    ((select username, assignment_id, count(group_id) as marked_nums
      from summarygraders
      group by username, assignment_id)table1
    
      JOIN

      (select assignment_id, count(group_id) as should_be
      from AssignmentGroup
      group by assignment_id)table2

      WHERE table1.assignment_id = table2.assignment_id)table3
    where marked_nums = should_be;



CREATE VIEW Final as
    select distinct username as ta
    from grader_marked_all_assign NATURAL JOIN grader_marked_all_for_one;


-- Final answer.
INSERT INTO q7 (select * from Final);
	-- put a final query here so that its results will go into the table.