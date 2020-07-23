-- If there is already any data in these tables, empty it out.

TRUNCATE TABLE Result CASCADE;
TRUNCATE TABLE Grade CASCADE;
TRUNCATE TABLE RubricItem CASCADE;
TRUNCATE TABLE Grader CASCADE;
TRUNCATE TABLE Submissions CASCADE;
TRUNCATE TABLE Membership CASCADE;
TRUNCATE TABLE AssignmentGroup CASCADE;
TRUNCATE TABLE Required CASCADE;
TRUNCATE TABLE Assignment CASCADE;
TRUNCATE TABLE MarkusUser CASCADE;


-- Now insert data from scratch.

INSERT INTO MarkusUser VALUES ('i1', 'iln1', 'ifn1', 'instructor');
INSERT INTO MarkusUser VALUES ('s1', 'sln1', 'sfn1', 'student'); -- s1, s2 组队2000 做 1000 assignment A1
INSERT INTO MarkusUser VALUES ('s2', 'sln2', 'sfn2', 'student');
INSERT INTO MarkusUser VALUES ('t1', 'tln1', 'tfn1', 'TA');
INSERT INTO MarkusUser VALUES ('s3', 'solo', 'work', 'student'); -- s3 单刷 7000 A2
INSERT INTO MarkusUser VALUES ('s4', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s5', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s6', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s7', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s8', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s9', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s10', 'solo', 'work', 'student'); 
INSERT INTO MarkusUser VALUES ('s11', 'solo', 'work', 'student'); 

INSERT INTO Assignment VALUES (1000, 'A1', '2017-02-08 20:00', 1, 2);
INSERT INTO Assignment VALUES (7000, 'A2', '2017-02-09 20:00', 1, 2);

INSERT INTO Required VALUES (1000, 'A1.pdf');
INSERT INTO Required VALUES (7000, 'A2.pdf');


INSERT INTO AssignmentGroup VALUES (2000, 1000, 'repo_url'); -- s1, s2 2000 做 1000 A1
INSERT INTO AssignmentGroup VALUES (3000, 1000, 'repo_url');
INSERT INTO AssignmentGroup VALUES (1, 7000, 'repo_url'); -- s3
INSERT INTO AssignmentGroup VALUES (2, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (3, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (4, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (5, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (6, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (7, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (8, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (9, 7000, 'repo_url'); 
INSERT INTO AssignmentGroup VALUES (4000, 7000, 'repo_url');

INSERT INTO Membership VALUES ('s1', 2000);
INSERT INTO Membership VALUES ('s2', 2000);
INSERT INTO Membership VALUES ('s3', 1); -- s3 自己组队
INSERT INTO Membership VALUES ('s4', 2);
INSERT INTO Membership VALUES ('s5', 3);
INSERT INTO Membership VALUES ('s6', 4);
INSERT INTO Membership VALUES ('s7', 5);
INSERT INTO Membership VALUES ('s8', 6);
INSERT INTO Membership VALUES ('s9', 7);
INSERT INTO Membership VALUES ('s10', 8);
INSERT INTO Membership VALUES ('s11', 9);
INSERT INTO Membership VALUES ('s1', 4000);
INSERT INTO Membership VALUES ('s2', 4000);

INSERT INTO Submissions VALUES (2000, 'A1.pdf', 's1', 2000, '2017-02-08 19:59');
INSERT INTO Submissions VALUES (4000, 'A2.pdf', 's1', 4000, '2017-02-08 19:59');

INSERT INTO Grader VALUES (2000, 't1');
INSERT INTO Grader VALUES (3000, 't1');
INSERT INTO Grader VALUES (1, 't1');
INSERT INTO Grader VALUES (2, 't1');
INSERT INTO Grader VALUES (3, 't1');
INSERT INTO Grader VALUES (4, 't1');
INSERT INTO Grader VALUES (5, 't1');
INSERT INTO Grader VALUES (6, 't1');
INSERT INTO Grader VALUES (7, 't1');
INSERT INTO Grader VALUES (8, 't1');
INSERT INTO Grader VALUES (9, 't1');
INSERT INTO Grader VALUES (4000, 't1');

INSERT INTO RubricItem VALUES (4000, 1000, 'style', 4, 0.25);
INSERT INTO RubricItem VALUES (4001, 1000, 'tester', 12, 0.75);
INSERT INTO RubricItem VALUES (4003, 7000, 'style', 4, 0.25);
INSERT INTO RubricItem VALUES (4004, 7000, 'tester', 12, 0.75);

INSERT INTO Grade VALUES (2000, 4000, 3);
INSERT INTO Grade VALUES (2000, 4001, 9);
INSERT INTO Grade VALUES (1, 4003, 4);
INSERT INTO Grade VALUES (1, 4004, 12);
INSERT INTO Grade VALUES (2, 4003, 4);
INSERT INTO Grade VALUES (2, 4004, 12);
INSERT INTO Grade VALUES (3, 4003, 4);
INSERT INTO Grade VALUES (3, 4004, 12);
INSERT INTO Grade VALUES (4, 4003, 4);
INSERT INTO Grade VALUES (4, 4004, 12);
INSERT INTO Grade VALUES (5, 4003, 4);
INSERT INTO Grade VALUES (5, 4004, 12);
INSERT INTO Grade VALUES (6, 4003, 4);
INSERT INTO Grade VALUES (6, 4004, 12);
INSERT INTO Grade VALUES (7, 4003, 4);
INSERT INTO Grade VALUES (7, 4004, 12);
INSERT INTO Grade VALUES (8, 4003, 4);
INSERT INTO Grade VALUES (8, 4004, 12);
INSERT INTO Grade VALUES (9, 4003, 4);
INSERT INTO Grade VALUES (9, 4004, 12);

INSERT INTO Result VALUES (2000, 12, true);
INSERT INTO Result VALUES (1, 16, true);
INSERT INTO Result VALUES (2, 16, true);
INSERT INTO Result VALUES (3, 16, true);
INSERT INTO Result VALUES (4, 16, true);
INSERT INTO Result VALUES (5, 16, true);
INSERT INTO Result VALUES (6, 16, true);
INSERT INTO Result VALUES (7, 16, true);
INSERT INTO Result VALUES (8, 16, true);
INSERT INTO Result VALUES (9, 16, true);
INSERT INTO Result VALUES (4000, 12, true);
