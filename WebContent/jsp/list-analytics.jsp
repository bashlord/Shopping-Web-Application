<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<!--  Include the UserInfo page -->
<title>Sales Page</title>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script> 
    <script type="text/javascript">
    	function updateTable(name){
    		console.log(name);
    		$.ajax({
    			  type: 'POST',
    			  url: "SalesProductsAjax.jsp" ,
    			  data: "name=" + name,
    			  beforeSend:function(){
    				//Update Stats
    				console.log('Request Sent');
    			//	$("#").html().css("color", "black");
    			  },
    			  success:function(data){
    			  
    			 var response = $.parseJSON(data);
    			  
    			  var i = Object.keys(response).length-1;
    			  console.log(response);
    			  while ( i >= 0 ){
    				  var keyStr = Object.keys(response)[i];
    				  console.log("#" + keyStr + "." + name + " $" + response[keyStr]);
    				  $("#" + keyStr + ">." + name).html("$" + response[keyStr]).css("color", "red");
    				  i--;
    			  }
    			  //console.log(Object.keys(response)[0]);
    			  	console.log("Success");
    			  },
    			  error:function(){
    				// Failed request
    				console.log("FAIL");
    			  }
    			});
    	}
    	
    </script>
</head>
<body>

		<%-- -------- Open Connection Code -------- --%>
     <%
     
     Connection conn = null;
     Statement query = null;
     Statement query2 = null;
     Statement query3 = null;
     ResultSet result2 = null;
     ResultSet statesR = null;
     ResultSet result = null;
     ResultSet stateIDR = null;
     ResultSet tableFillResult = null;
     ResultSet rs = null;
     ResultSet productSalesR = null;
     ResultSet customerTotalR = null;
     ResultSet stateTotalR = null;
     ResultSet updatedProducts = null;

     
     
     try {
    	 //if (session.getAttribute("role") != null && session.getAttribute("role").equals("Owner")){
    	if (true){
         // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost:5432/smalldb";
        String user = "postgres";
        String password = "postgres";
        conn = DriverManager.getConnection(url, user, password);

         
     	/**** GET ALL FILTERS AND SHIT  *****/    
         String action = request.getParameter("rowstatus");
     	String rowsView = request.getParameter("rowsView");
     	String quarter = request.getParameter("quarter");

     	
     	boolean rowsAreCustomers = true;
     	if (rowsView != null && rowsView.equals("States")){
     		rowsAreCustomers = false;
     	}
     	
     	/**** END GET ALL FILTERS AND SHIT ****/
     %>
    

    <%-- -------- INSERT Code -------- --%>
    <%
    
        // Check if an insertion is requested
        	//System.out.println("In Sign up");
            // Begin transaction
            conn.setAutoCommit(false);

            Statement tableDrop = conn.createStatement();
            tableDrop.executeUpdate("DROP TABLE IF EXISTS StateProducts CASCADE");
            Statement createTable = conn.createStatement();
            createTable.executeUpdate("CREATE TABLE StateProducts AS (" +
            				"SELECT sales.uid, users.name as username, SUM(sales.price*sales.quantity) AS totalCost, sales.pid, products.name as name, SUM(quantity) as quantity, categories.name as cid, states.name as state, states.id as stateID, products.price " +
            				"FROM users, products, sales, categories, states " +
            				"WHERE sales.uid = users.id AND sales.pid = products.id AND categories.id = products.cid AND states.id = users.state " +
            				"GROUP BY username, sales.uid, sales.price, sales.quantity, products.name, sales.pid, products.price, products.cid, states.name, states.id, categories.name " +
            				"ORDER BY SUM(sales.price*sales.quantity) DESC)");
            
            
            
            // Create the prepared statement and use it to
            // INSERT student values INTO the students table.
			String statesQ ="SELECT sp.state as state FROM (SELECT state, totalCost FROM StateProducts) as sp GROUP BY sp.state ORDER BY SUM(totalCost) DESC LIMIT 50 ";
            String q = "SELECT sp.state, sp.name, SUM(totalCost) as totalCost FROM StateProducts AS sp WHERE sp.name IN (SELECT name FROM TopProducts LIMIT 50) AND " +
    				"sp.state IN (SELECT state FROM TopStates) GROUP BY sp.state, sp.name ORDER BY SUM(totalCost) DESC";
            
    		String productsQK = "SELECT name FROM (SELECT name, totalCost FROM StateProducts) as lol"+
					" GROUP BY name ORDER BY SUM(totalCost) DESC LIMIT 50";
            
            Statement dropQ1 = conn.createStatement();
            dropQ1.executeUpdate("DROP TABLE IF EXISTS TopProducts CASCADE");
            Statement dropQ2 = conn.createStatement();
            dropQ2.executeUpdate("DROP TABLE IF EXISTS TopStates CASCADE");
            

            Statement createTable1 = conn.createStatement();
            createTable1.executeUpdate("CREATE TABLE TopStates AS("+ statesQ +")");
            Statement createTable2 = conn.createStatement();
            createTable2.executeUpdate("CREATE TABLE TopProducts AS("+ productsQK +")");
            
    		String getStatesQ = "SELECT state as name FROM TopStates LIMIT 50";
   		 query = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
         result = query.executeQuery(getStatesQ);
            
         String getStatesID = "SELECT sp.stateID FROM (SELECT stateID, totalCost FROM StateProducts) as sp GROUP BY sp.stateID ORDER BY SUM(totalCost) DESC LIMIT 50";
         query = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
         stateIDR = query.executeQuery(getStatesID);
         
         String upProd = "SELECT product FROM newSales GROUP BY product";
   		 query = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
         updatedProducts = query.executeQuery(upProd);
         
         
         
         String getProductsQ = "SELECT name FROM TopProducts LIMIT 50";
         query2 = conn
         .createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
         result2 = query2.executeQuery(getProductsQ);
         query3 = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
         tableFillResult = query3.executeQuery(q);
         
         String productSalesQ = "SELECT name, SUM(totalCost) AS total FROM StateProducts GROUP BY name ORDER BY SUM(totalCost) DESC LIMIT 50";
 		query = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
 		productSalesR = query.executeQuery(productSalesQ);
 		
		String stateTotalQ = "SELECT state as state, SUM(totalCost) as total FROM StateProducts GROUP BY state ORDER BY SUM(totalCost) DESC LIMIT 50";

		query = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
		stateTotalR = query.executeQuery(stateTotalQ);
         
            String[] states = new String[50];
     		int a = 0;
     		while(result.next()){
     			states[a] = result.getString("name");
     			a++;
     		}
    	
     		result.beforeFirst(); 
            int resultSize = 0;
            while (result.next()){
            	resultSize+=1;
            }
            result.beforeFirst();
     %>
            
            <table border="1">
            <%
      			String[] productNames = new String[50];
      			int[] productPrices = new int[50];
      			int productSize = 0;
          		while(result2.next() && resultSize > 0){
          			productNames[productSize] = result2.getString("name");
          			//System.out.print(productNames[productSize] + " : ");
          			productSize++;
          		}
          		
          		for (int i = 0; i < productNames.length; ++i){
          			productSalesR.beforeFirst();
          			while (productSalesR.next()){
          				if (productSalesR.getString("name").equals(productNames[i])){
          					productPrices[i] = productSalesR.getInt("total");
          					break;
          				}
          			}
          		}
         		for ( int j = 0; j < resultSize+1; ++j ){
            		if(j != 0){
  						if (!stateIDR.next()){
      						stateIDR.beforeFirst();
      					}
            			%><tr id = <%="'"+stateIDR.getInt("stateID")+"'"%> >
            			<%
            		}else{
            			%><tr><%
            		}           			
            	%>
            		<%
          			if ( j == 0 ){ //for first row
          				for ( int k = 0; k < productSize+1; ++k ){ //11 cols
          					if ( k == 0 ){ 
          						%><th>State / Sales Total</th><%
          						continue;
          					}
          		%>	
          				<th><%=productNames[k-1]%> / $<%=productPrices[k-1]%></th>
          		<%
          				}
          				%></tr><%
          			} //end first row code
          			else{
          				
          				for ( int k = 0; k < productSize+1; ++k ){ //11 cols
          					boolean updatedTable = false;
          					int totalAmount = 0;
	      					if ( k == 0 ){ 
	      						if (!result.next()){
	          						result.first();
	          					}
	      						//stateTotalR.beforeFirst();
	      						while(stateTotalR.next()){
	      		//	System.out.println("State: " + stateTotalR.getString("state") + " RESULT STATE " + result.getString("name"));
  									if (result.getString("name").equals(stateTotalR.getString("state"))){
  										totalAmount = stateTotalR.getInt("total");
  										//System.out.println("State: " + stateTotalR.getString("state") + " AMOUNT " + totalAmount);
  										break;
  									}
  								}
	      					%>
	      						<td><%=result.getString("name")%> / $<%=totalAmount%></td>
	      					<%	
	      						continue;
          					}
	      						int cellQuantity = 0;
	      						int itemSales = 0;
          						tableFillResult.beforeFirst();
	          					while ( tableFillResult.next() ){
	          						//System.out.println("Pname: " + productNames[k-1] + "; Name: " + tableFillResult.getString("name"));
	          						if ( productNames[k-1].equals(tableFillResult.getString("name"))){
		          						if ( result.getString("name").equals(tableFillResult.getString("state")) ){
		          							itemSales += tableFillResult.getInt("totalCost");
		          							break;
		          						}

		          					}
          						}
	          					%> <td class = <%=productNames[k-1]%>>$<%=itemSales%></td>  <%      				
          		%>
          			
          		<%
          			}	
          		}
          			%> <tr> <%
          	}
          	%>

          	</table>     	
    <% 
            
            // Commit transaction
            conn.commit();
            conn.setAutoCommit(true);
    %>
    <%-- -------- Close Connection Code -------- --%>
    <%
        // Close the Connection
        	conn.close();
       }

    %>
    <%-- -------- Error catching ---------- --%>
    <%
     } catch (SQLException e) {
    	 //System.out.println("In catch");
        // Wrap the SQL exception in a runtime exception to propagate
        // it upwards
        throw new RuntimeException(e);
    }
    finally {
        // Release resources in a finally block in reverse-order of
        // their creation
		//System.out.println("In finally");
        if (query != null) {
            try {
                query.close();
            } catch (SQLException e) { } // Ignore
            query = null;
        }            try {
                conn.close();
            } catch (SQLException e) { } // Ignore
            conn = null;
        }
    
    %>  
	<script type="text/javascript">

			$(document).ready(function(){
				$('#button-refresh').click(function(){
					getChanges();
				});
			});

			function getChanges(){
				<% 
				System.out.println("getChanges()asfc");
				updatedProducts.beforeFirst(); 
				while (updatedProducts.next()){	
				//	System.out.println("BEFORE UPDATE TABLE CALL Product: " + updatedProducts.getString("product"));
					%>updateTable("<%=updatedProducts.getString("product")%>");<%
					//System.out.println("Product: " + result2.getString("name"));
	    		}
	    		%>
    	 }
	   	                     			
			//setInterval(getChanges,90000000);
</script>
	<input type="button" value="Refresh" id="button-refresh" >
</body>
</html>