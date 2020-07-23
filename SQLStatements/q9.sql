-- Inseparable

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q9;

-- You must not change this table definition.
CREATE TABLE q9 (
	student1 varchar(25),
	student2 varchar(25)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW Pairs as
    select m1.username as username1, m1.surname as surename1, 
           m2.username as username2, m2.surname as surename2
    from MarkusUser m1, MarkusUser m2
    where (m1.type = m2.type = 'student') and (m1.surename < m2.username);

CREATE VIEW Pairs_Membership as
    select s1.group_id as group_id, s1.username as username1, s2.username as username2
    from Membership s1, Membership s2
    where s1.group_id = s2.group_id
    group by s1.group_id;

CREATE VIEW students_did_paired as
    select group_id, username1, username2
    from Pairs_Membership NATURAL JOIN Pairs;

CREATE VIEW Selected_groups as
    select group_id, assignment_id
    from AssignmentGroup NATURAL JOIN Assignment
    where group_min > 1;

CREATE VIEW students_did_pair_assign as
    select group_id, username1, username2, (username1 || username2) as students_names, assignment_id
    from students_did_paired NATURAL JOIN Selected_groups;

CREATE VIEW num_assign as
    select group_id, username1, username2, count(distinct assignment_id)
    from students_did_pair_assign
    group by assignment_id;

CREATE VIEW num_students_names as
    select group_id, username1, username2, count(distinct students_names) as count1
    from students_did_pair_assign
    group by students_names;

CREATE VIEW Final as
    select username1 as student1, username2 as student2
    from num_assign NATURAL JOIN num_students_names
    where count1 = count2;


-- Final answer.
INSERT INTO q9 (select * from Final);
	-- put a final query here so that its results will go into the table.
