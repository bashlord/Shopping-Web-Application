<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@page
    import="java.util.List"
    import="helpers.*"%>
<%=CategoriesHelper.modifyCategories(request)%>
<div class="panel panel-default">
	<div class="panel-body">
		<div class="bottom-nav">
            <h4> Options </h4>
		<%
		List<CategoryWithCount> categories = CategoriesHelper
		.listCategories();
		/*	String action = request.getParameter("rowstatus");
			String rowsView = request.getParameter("rowsView");
	    	String displaychoice = request.getParameter("displaychoice");
	    	String category = request.getParameter("categories");
	    	boolean rowsAreCustomers = true;
	    	if(rowsView != null && rowsView.equals("States")){
	    		rowsAreCustomers = false;
	    	}*/
		%>
		  <form action="analytics" method="post">
	<div>View by:
		<select name="rowsView">
			<option value="Customer">Customer</option>
			<option value="States">States</option>
		</select>
		<br />
	</div>
	<span>Ordering:
		<select name="displaychoice">
		<option value="Alphabetical">Alphabetical</option>
		<option value="Top-K">Top-K</option>
		</select>   
	</span> 
	
	<span>Product Categories:
		<select name="categories">
		    <option value="all" selected="selected">All Categories</option>
		<%

		for (CategoryWithCount cwc : categories) {
                	%> <option value="<%=cwc.getName()%>"><%=cwc.getName()%></option><%
                }
         %>
         </select>
         </span>
         
                
		<input type="hidden" name="rowstatus" value="yes" />
		<input type="submit" value="Run Query" />

		</div>
	</div>
</div>