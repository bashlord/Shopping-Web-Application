<%@page import="java.util.*" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.postgresql.util.*" %>
<%@ page import="java.sql.*"%>
<%
	application.setAttribute("database","shopping");
	Calendar calendar = Calendar.getInstance();
	int month = calendar.get(Calendar.MONTH) + 1;
	int day = calendar.get(Calendar.DAY_OF_MONTH);
	Connection conn = null;
	//request.getParameter("state")
  try {
    // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost:5432/smalldb";
        String user = "postgres";
        String password = "postgres";
        conn = DriverManager.getConnection(url, user, password);
    
    conn.setAutoCommit(false);
    
    Statement tableDrop = conn.createStatement();
    tableDrop.executeUpdate("DROP TABLE IF EXISTS StateProducts CASCADE");
    Statement createTable = conn.createStatement();
    createTable.executeUpdate("CREATE TABLE StateProducts AS (" +
    				"SELECT sales.uid, users.name as username, SUM(sales.price*sales.quantity) AS totalCost, sales.pid, products.name as name, SUM(quantity) as quantity, categories.name as cid, states.name as state, states.id as stateID, products.price FROM users, products, sales, categories, states WHERE sales.uid = users.id AND sales.pid = products.id AND categories.id = products.cid AND states.id = users.state GROUP BY username, sales.uid, sales.price, sales.quantity, products.name, sales.pid, products.price, products.cid, states.name, states.id, categories.name ORDER BY SUM(sales.price*sales.quantity) DESC)");
    
	JSONObject result = new JSONObject();
	Statement getSales = conn.createStatement();
	String getSalesQ = "SELECT stateID, SUM(totalCost) as total FROM StateProducts WHERE name = '" 
						+ request.getParameter("name") +
						"' AND stateID IN (SELECT stateID FROM newSales) GROUP BY stateID, name ORDER BY name ASC LIMIT 50";
	//System.out.println(getSalesQ);
	//System.out.println(request.getParameter("name"));
	ResultSet rs = getSales.executeQuery(getSalesQ);
	while (rs.next()){
		System.out.println("INSIDE result set RESULT PUT");
		result.put(rs.getString("stateID"), rs.getString("total"));
		//System.out.println("state: " + rs.getString("state") + " totalCost: " + rs.getString("total") + "  PROD NAME : " + request.getParameter("name"));
	}
	//rs.first();
	
	Statement del = conn.createStatement();
	String getdel = "SELECT stateID, SUM(totalCost) as total FROM StateProducts WHERE name = '" 
						+ request.getParameter("name") +
						"' AND stateID IN (SELECT stateID FROM newSales) GROUP BY stateID, name ORDER BY name ASC LIMIT 50";
	ResultSet delR = del.executeQuery(getdel);
	
	while (delR.next()){
		System.out.println( "stateid:  " + delR.getString("stateID") + "AND product = " + "'" +request.getParameter("name"));
	Statement stmt = conn.createStatement();
    String deleteNew = "DELETE FROM newSales WHERE stateID = "  + delR.getString("stateID") + "AND product = " + "'" +request.getParameter("name")+"'";
     stmt.execute(deleteNew);
	}
	//System.out.println("DONE WITH WHILE LOOP");
	out.print(result);
	out.flush();
	conn.commit();
    conn.setAutoCommit(true);
    conn.close();
  } catch(SQLException e){
	  //System.out.println("There was an error getting this request.");
	  throw e;
  }
	
%>