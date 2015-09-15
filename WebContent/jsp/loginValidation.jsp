<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@page import="org.json.simple.*"%>
<%@ page import="org.postgresql.util.*" %>
<%@page
    import="java.util.List"
    import="helpers.*"%>
    
    <%
    /* The JSON and AJAX here is utilized slightly differently from the 
     * analytics table. In this case the JSON is only sending a true or false
     * value denoting a successful insertion or not. 
     */
     
    Connection conn = null;
    Statement stmt;
    
    //grab all the form elements
   	String state = request.getParameter("state");
    String name = request.getParameter("name");
   	String role = request.getParameter("role");
   	int age = Integer.parseInt(request.getParameter("age"));
   
    try {
    	
    	//get convert the state string into its respective id number to fit in users table
        int stateId = helpers.SignupHelper.getStateId(state);
    	
    	//prepare the insertion statement
        String SQL = "INSERT INTO users (name, role, age, state) VALUES('" + name + "','" + role + "'," + age
                + ",'" + stateId + "');";
                
        //attempt database connection
        try {
            conn = HelperUtils.connect();
        } 
        
      	//if JDBC fails somehow
        catch (Exception e) {
            System.out.println("Could not register PostgreSQL JDBC driver with the DriverManager");
        }
        
        //execute the query from above
        stmt = conn.createStatement();
        try {
            conn.setAutoCommit(false);
            stmt.execute(SQL);
            conn.commit();
            conn.setAutoCommit(true);
        } 
        
        //if insertion fails then the connection is an error
        //so technically this is bad, we never want to get here
        catch (SQLException e) {
            
            JSONObject result = new JSONObject();
            result.put("success", false);
            out.print(result);
		    out.flush();
		    return;
        }
        conn.close();
        
    }
    
    //if there are any other errors, stop here
    catch (Exception e) {
        //String output = "A problem happened while interacting with the database : \n" + e.getLocalizedMessage();
        //return HelperUtils.printError(output);
    }

    String output = "<h4>Registered successfully!</h4> <br>";
    output += "<table><tr><td>Name: </td><td>" + name + "</td></tr><tr><td>Role:</td><td>" + role
            + "</td></tr><tr><td>Age:</td><td>" + age + "</td></tr><tr><td>State:</td><td>" + state
            + "</td></tr></table>";
    
    //otherswise the connection is successful and the result 
    //of the query will be parsed by the javascript function in signup.jsp
    JSONObject result = new JSONObject();    
    result.put("success", true); 
    out.print(result);
    out.flush();
	%>