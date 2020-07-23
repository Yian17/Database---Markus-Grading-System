-- Never solo by choice

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q8;

-- You must not change this table definition.
CREATE TABLE q8 (
  username varchar(25),
  group_average real,
  solo_average real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Find all students in MarkusUser
CREATE VIEW students as
    select username
    from MarkusUser
    where type = 'student';

-- Find assignment_id that allow student to group
CREATE VIEW allowed_groups as
    select assignment_id
    from Assignment
    where group_max > 1; 

-- Find the assignment not allow solo work
CREATE VIEW not_allowed_groups as
    select assignment_id
    from Assignment
    where group_max = 1; 

-- Find the summary of allowed groups for a assignment
CREATE VIEW Shouldhave as 
    select assignment_id, group_id, username
    from AssignmentGroup NATURAL JOIN allowed_groups NATURAL JOIN Membership;

-- Find the student choose to solo for group assignment
CREATE VIEW Notpair as 
    select assignment_id, group_id
    from Shouldhave
    group by assignment_id, group_id
    having count(username) = 1;

-- Students worked alone
CREATE VIEW students_worked_alone as 
    select username
    from Notpair NATURAL JOIN Shouldhave;

-- Students never worked alone
CREATE VIEW students_never_alone as 
    (select username
    from Shouldhave)
    EXCEPT
    (select username
    from students_worked_alone);

-- Students submitted every assignment
CREATE VIEW students_submitted_every_assign as
    select username
    from Submissions NATURAL JOIN Required
    group by username
    having count(distinct assignment_id) = (select count(distinct assignment_id)
                                            from Assignment);

-- the students qulified for our query
CREATE VIEW students_qualified as
    select students_never_alone.username as username
    from students_never_alone, students_submitted_every_assign
    where students_never_alone.username = students_submitted_every_assign.username;

-- combine the username and group_id info
CREATE VIEW user_groups as
    select username, group_id
    from students_qualified NATURAL JOIN Membership;

-- helper table
CREATE VIEW table1 as
    select group_id, assignment_id
    from AssignmentGroup;

-- students did solo for only solo allowed assignment
CREATE VIEW users_haveto_solo as
    select username, group_id, assignment_id
    from user_groups NATURAL LEFT JOIN (table1 NATURAL JOIN not_allowed_groups);

-- students did group work when groups are allowed
CREATE VIEW user_did_group as
    select username, group_id, assignment_id
    from user_groups NATURAL JOIN table1 NATURAL JOIN allowed_groups;

-- find percentages of each group
CREATE VIEW denom as
    select assignment_id, sum(cast(out_of as real) * weight) as denominator
    from RubricItem
    group by assignment_id;

CREATE VIEW weighted_grade as
    select group_id, Grade.rubric_id as rubric_id, assignment_id, cast(grade as real) * weight as weighted_grade
    from RubricItem, Grade
    where RubricItem.rubric_id = Grade.rubric_id;

CREATE VIEW num as
    select group_id, assignment_id, sum(weighted_grade) as numerator
    from weighted_grade
    group by group_id, assignment_id;

CREATE VIEW percentage_for_each_group as
    select num.group_id as group_id, num.assignment_id as assignment_id, 100 * numerator/denominator AS grade
    from denom, num
    where denom.assignment_id = num.assignment_id;
--//

-- students did solo work
CREATE VIEW usersolo as
    select username, avg(grade) as solo_average
    from users_haveto_solo NATURAL LEFT JOIN percentage_for_each_group 
    group by username;

--users did group work
CREATE VIEW usersgroups as
    select username, avg(grade) as group_average
    from user_did_group NATURAL LEFT JOIN percentage_for_each_group
    group by username;

-- Combine the solo average and group average for qualified students
CREATE VIEW Final as
    select usersolo.username, group_average, solo_average
    from usersolo, usersgroups
    where usersolo.username = usersgroups.username;


-- Final answer.
INSERT INTO q8 (select * from Final);
  -- put a final query here so that its results will go into the table.