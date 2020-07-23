-- A1 report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q10;

-- You must not change this table definition.
CREATE TABLE q10 (
  group_id integer,
  mark real,
  compared_to_average real,
  status varchar(5)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

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

-- Find A1
CREATE VIEW assign1 as
    select assignment_id
    from Assignment
    where description = 'A1';

CREATE VIEW percentage_for_each_group_for_A1 as
    select group_id, assignment_id, grade
    from percentage_for_each_group NATURAL LEFT JOIN assign1;

CREATE VIEW a1_average as
    select assignment_id, (sum(grade)/count(group_id)) as a1_average
    from percentage_for_each_group_for_A1
    group by assignment_id;

CREATE VIEW summary_with_a1_average as
    select group_id, assignment_id, grade, a1_average
    from percentage_for_each_group_for_A1 NATURAL LEFT JOIN a1_average;

CREATE VIEW Combine as
    select group_id, grade as mark, (grade - a1_average) as compared_to_average, a1_average
    from summary_with_a1_average;

CREATE VIEW Final as
    select group_id, mark, compared_to_average, status
    from
    (select group_id, mark, compared_to_average, 'above':: text as status
       from Combine
       where mark > a1_average)above

       ,

      (select group_id, mark, compared_to_average, 'at' :: text as status
       from Combine
       where mark = a1_average)above_at

       ,

      (select group_id, mark, compared_to_average, 'below' :: text as status
       from Combine
       where mark < a1_average)below;


-- Final answer.
INSERT INTO q10 (select * from Final);
  -- put a final query here so that its results will go into the table.
