import java.sql.*;

// Remember that part of your mark is for doing as much in SQL (not Java) 
// as you can. At most you can justify using an array, or the more flexible
// ArrayList. Don't go crazy with it, though. You need it rarely if at all.
import java.util.ArrayList;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to the database and sets the search path.
     * 
     * Establishes a connection to be used for this session, assigning it to the
     * instance variable 'connection'. In addition, sets the search path to
     * markus.
     * 
     * @param url
     *            the url for the database
     * @param username
     *            the username to be used to connect to the database
     * @param password
     *            the password to be used to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
        try{ 
            connection = DriverManager.getConnection(URL, username, password);
            Statement constat = connection.createStatement();
            constat.execute("SET SEARCH_PATH TO markus;");
            //constat.close()

        }catch(SQLException se){
            return false;
        }
        return true;
    }

    /**
     * Closes the database connection.
     * 
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
        try{
            connection.close();
        }catch(SQLException se){
           return false;
        }
        return true;
    }

    /**
     * Assigns a grader for a group for an assignment.
     * 
     * Returns false if the groupID does not exist in the AssignmentGroup table,
     * if some grader has already been assigned to the group, or if grader is
     * not either a TA or instructor.
     * 
     * @param groupID
     *            id of the group
     * @param grader
     *            username of the grader
     * @return true if the operation was successful, false otherwise
     */
    public boolean assignGrader(int groupID, String grader) {

        PreparedStatement pstat;
        ResultSet rs;

        try{
            //Returns false if the groupID does not exist in the AssignmentGroup table.
            String findGroupID = "SELECT * FROM AssignmentGroup WHERE group_id = ?";
            pstat = connection.prepareStatement(findGroupID);
            pstat.setInt(1, groupID);
            rs = pstat.executeQuery();
            if (!rs.next()) { 
                return false;
            }

            //Returns false if some grader has already been assigned to the group.
            String findGraderAssigned = "SELECT * FROM Grader WHERE group_id = ?";
            pstat = connection.prepareStatement(findGraderAssigned);
            pstat.setInt(1, groupID);
            rs = pstat.executeQuery();
            if (rs.next()) { 
                return false;
            }

            //Returns false if grader is not either a TA or instructor.
            String ifGraderStudent = "SELECT * FROM MarkusUser WHERE username = ? and type = 'student'";
            pstat = connection.prepareStatement(ifGraderStudent);
            pstat.setString(1, grader);
            rs = pstat.executeQuery();
            if (rs.next()) { 
                return false;
            }

            //Assigns a grader for a group for an assignment.
            String forAssign = "INSERT INTO Grader VALUES (?, ?)";
            pstat = connection.prepareStatement(forAssign);
            pstat.setInt(1, groupID);
            pstat.setString(2, grader);
            int ifAssign = pstat.executeUpdate();
            if (ifAssign > 0) { 
                return true;
            } else {
                return false;
            }

        }catch(SQLException se){
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
        }

        return false;
    }

    /**
     * Adds a member to a group for an assignment.
     * 
     * Records the fact that a new member is part of a group for an assignment.
     * Does nothing (but returns true) if the member is already declared to be
     * in the group.
     * 
     * Does nothing and returns false if any of these conditions hold: - the
     * group is already at capacity, - newMember is not a valid username or is
     * not a student, - there is no assignment with this assignment ID, or - the
     * group ID has not been declared for the assignment.
     * 
     * @param assignmentID
     *            id of the assignment
     * @param groupID
     *            id of the group to receive a new member
     * @param newMember
     *            username of the new member to be added to the group
     * @return true if the operation was successful, false otherwise
     */
    public boolean recordMember(int assignmentID, int groupID, String newMember) {

        PreparedStatement pstat;
        ResultSet rs;
        int capacity = 0;
        int alreadyHad = 0;

        try{

            //Returns true if the member is already declared to be in the group.
            String conditioncheck = "SELECT * FROM Membership " + 
                                    "WHERE username = ? AND group_id = ?";
            pstat = connection.prepareStatement(conditioncheck);
            pstat.setString(1, newMember);
            pstat.setInt(2, groupID);
            rs = pstat.executeQuery();
            if(rs.next()){
                return true;
            } 

            //Returns false if some the group is already at capacity.
            String findCapacity = "SELECT group_max " + 
                                  "FROM Assignment " + 
                                  "WHERE assignment_id = ?";
            pstat = connection.prepareStatement(findCapacity);
            pstat.setInt(1, assignmentID);
            rs = pstat.executeQuery();
            if(rs.next()){
                capacity = rs.getInt("group_max");
            }
            String countInGroup = "SELECT group_id, count(username) as alreadyExist " + 
                                  "FROM Membership " + 
                                  "GROUP BY group_id" +
                                  "HAVING group_id = ?"; 
            pstat = connection.prepareStatement(countInGroup);
            pstat.setInt(1, groupID);
            rs = pstat.executeQuery();
            if(rs.next()){
                alreadyHad = rs.getInt("alreadyExist");
            }
            if(capacity == alreadyHad){
                return false;
            }

            //Returns false if newMember is not a valid username or is not a student.
            String ifStudent = "SELECT * FROM MarkusUser " +
                               "WHERE username = ? AND type = 'student'";
            pstat = connection.prepareStatement(ifStudent);
            pstat.setString(1, newMember);
            rs = pstat.executeQuery();
            if (!rs.next()){
                return false;
            }

            //Returns false if there is no assignment with this assignment ID.
            String ifAssign = "SELECT * FROM Assignment " +
                              "WHERE assignment_id = ?";
            pstat = connection.prepareStatement(ifAssign);
            pstat.setInt(1, assignmentID);
            rs = pstat.executeQuery();
            if (!rs.next()){
                return false;
            }


            //Returns false if the group ID has not been declared for the assignment.
            String ifGroup = "SELECT * FROM AssignmentGroup " +
                             "WHERE assignment_id = ?, group_id = ?";
            pstat = connection.prepareStatement(ifGroup);
            pstat.setInt(1, assignmentID);
            pstat.setInt(2, groupID);
            rs = pstat.executeQuery();
            if (!rs.next()){
                return false;
            }

            //Adds a member to a group for an assignment.
            String forAdding = "INSERT INTO Membership VALUES (?, ?)";
            pstat = connection.prepareStatement(forAdding);
            pstat.setString(1, newMember);
            pstat.setInt(2, groupID);
            int ifAdded = pstat.executeUpdate();
            if (ifAdded > 0) { 
                return true;
            } else {
                return false;
            }

        }catch(SQLException se){
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
        }

        return false;

    }

    /**
     * Creates student groups for an assignment.
     * 
     * Finds all students who are defined in the Users table and puts each of
     * them into a group for the assignment. Suppose there are n. Each group
     * will be of the maximum size allowed for the assignment (call that k),
     * except for possibly one group of smaller size if n is not divisible by k.
     * Note that k may be as low as 1.
     * 
     * The choice of which students to put together is based on their grades on
     * another assignment, as recorded in table Results. Starting from the
     * highest grade on that other assignment, the top k students go into one
     * group, then the next k students go into the next, and so on. The last n %
     * k students form a smaller group.
     * 
     * In the extreme case that there are no students, does nothing and returns
     * true.
     * 
     * Students with no grade recorded for the other assignment come at the
     * bottom of the list, after students who received zero. When there is a tie
     * for grade (or non-grade) on the other assignment, takes students in order
     * by username, using alphabetical order from A to Z.
     * 
     * When a group is created, its group ID is generated automatically because
     * the group_id attribute of table AssignmentGroup is of type SERIAL. The
     * value of attribute repo is repoPrefix + "/group_" + group_id
     * 
     * Does nothing and returns false if there is no assignment with ID
     * assignmentToGroup or no assignment with ID otherAssignment, or if any
     * group has already been defined for this assignment.
     * 
     * @param assignmentToGroup
     *            the assignment ID of the assignment for which groups are to be
     *            created
     * @param otherAssignment
     *            the assignment ID of the other assignment on which the
     *            grouping is to be based
     * @param repoPrefix
     *            the prefix of the URL for the group's repository
     * @return true if successful and false otherwise
     */
    public boolean createGroups(int assignmentToGroup, int otherAssignment,
            String repoPrefix) {
        // Replace this return statement with an implementation of this method!
        PreparedStatement pstat;
        ResultSet rs;
        int assignMax = 0;
        int maxGroupNum = 0;
        ArrayList<String> usernameArray = new ArrayList<String>();
        boolean flag = true;

        try{
            String ifMarkus = "SELECT * FROM MarkusUser WHERE type = 'student'";
            pstat = connection.prepareStatement(ifMarkus);
            rs = pstat.executeQuery();
            if (!rs.next()) { 
                return true;
            }


            //Returns false if there is no assignment with ID assignmentToGroup
            String check_atog = "SELECT * FROM Assignment WHERE assignment_id = ?";
            pstat = connection.prepareStatement(check_atog);
            pstat.setInt(1, assignmentToGroup);
            rs = pstat.executeQuery();
            if (!rs.next()) { 
                return false;
            }

            //Returns false if there is no assignment with ID otherAssignment
            String check_oa = "SELECT * FROM Assignment WHERE assignment_id = ?";
            pstat = connection.prepareStatement(check_oa);
            pstat.setInt(1, otherAssignment);
            rs = pstat.executeQuery();
            if (!rs.next()) { 
                return false;
            }

            //Return false if any group has already been defined for this assignment
            String check_group = "SELECT * FROM AssignmentGroup WHERE assignment_id = ?";
            pstat = connection.prepareStatement(check_group);
            pstat.setInt(1, assignmentToGroup);
            rs = pstat.executeQuery();
            if (rs.next()) { 
                return false;
            }
            
            //
            String findMax = "SELECT group_max FROM Assignment WHERE assignment_id = ?";
            pstat = connection.prepareStatement(findMax);
            pstat.setInt(1, assignmentToGroup);
            rs = pstat.executeQuery();
            if (rs.next()) { 
                assignMax = rs.getInt("group_max");
            }

            String findNextGroup = "SELECT max(group_id) as max FROM AssignmentGroup";
            pstat = connection.prepareStatement(findNextGroup);
            rs = pstat.executeQuery();
            if (rs.next()) { 
                maxGroupNum = rs.getInt("max");
            }

            pstat = connection.prepareStatement("SELECT setval('Membership_group_id_seq', maxGroupNum)");
            pstat.executeQuery();

            String order = "SELECT username FROM " +
                           "(SELECT * FROM MarkusUser WHERE type = 'student')Students " +
                           "NATURAL LEFT JOIN AssignmentGroup NATURAL LEFT JOIN " +
                           "Membership NATURAL LEFT JOIN Result " +
                           "WHERE Assignment_id = ? ORDER BY mark DESC NULLS LAST, username";
            pstat = connection.prepareStatement(order);
            pstat.setInt(1, otherAssignment);
            rs = pstat.executeQuery();
            while(rs.next()){
                usernameArray.add(rs.getString("username"));
            }
            int i = 0;
            int limit = 0;
            int size = usernameArray.size();
            int newnum = maxGroupNum + 1;
            while(i < size){
                if (limit == assignMax){
                    limit = 0;
                }
                String createGroup = "INSERT INTO Membership(username) VALUES (?)";
                pstat = connection.prepareStatement(createGroup);
                pstat.setString(1, (String)usernameArray.get(i));
                int c = pstat.executeUpdate();
                if(c < 0){
                    flag = false;
                }

                String insertAG = "INSERT INTO AssignmentGroup VALUES (?, ?, ?)";
                pstat = connection.prepareStatement(insertAG);
                pstat.setInt(1, newnum);
                pstat.setInt(2, assignmentToGroup);
                String newrepo = repoPrefix + "/group_" + String.valueOf(newnum); 
                pstat.setString(3, newrepo);
                pstat.executeQuery();

                newnum ++;
                limit ++;
                size ++;
            }


        }catch(SQLException se){
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
        }


        return flag;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Boo!");
    }
}
