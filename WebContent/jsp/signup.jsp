<%@ page contentType="text/html; charset=utf-8" language="java"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/head.html" />

<script>
	function validation() {
		var send = true;
		
		//grab all the elements/fields of the form for validation
		var name = document.getElementById("name").value;
		var role = document.getElementById("role").value;
		var age = document.getElementById("age").value;
		var state = document.getElementById("state").value;
	
		//check for the empty name field
		if(name === "") {
			document.getElementById("nameTest").style.visibility = "visible";
			send = false;
		}
		else {
			document.getElementById("nameTest").style.visibility = "hidden";
		}
		
		//check for the empty role field
		if(role === "Select") {
			document.getElementById("roleTest").style.visibility = "visible";
			send = false;
		}
		else {
			document.getElementById("roleTest").style.visibility = "hidden";
		}
		
		//check for the empty age field
		if(age === "") {
			document.getElementById("ageTest").style.visibility = "visible";
			send = false;
		}
		else {
			document.getElementById("ageTest").style.visibility = "hidden";
		}
		
		//check for the empty state field
		if(state === "Select") {
			document.getElementById("stateTest").style.visibility = "visible";
			send = false;
		}
		else {
			document.getElementById("stateTest").style.visibility = "hidden";
		}

		if(send) {
		$.ajax({
			type: "POST",
			url: "/Project3/jsp/loginValidation.jsp",  //this is configured to my computer. you might need to change this depending on your setup
			data: {"name":name, "role":role, "age":age, "state":state},
			datatype: "JSON",
			
			//indicator that request was sent to db
			beforesend:function() {
				console.log("request sent");
			},
			
			//upon successful connection. NOT INSERTION
			success:function(result) {
				var response = $.parseJSON(result);
				console.log(response);
				
				//success message
				if(response.success) {
					/*var output = "<h3><b>Registered successfully!</b></h3> <br> <table><tr><td>Name:</td><td>" + name 
					+ "</td></tr><tr><td>Role:</td><td>" + role
	                + "</td></tr><tr><td>Age:</td><td>" + age + "</td></tr><tr><td>State:</td><td>" + state
	                + "</td></tr></table>"*/
	                
	                //hide username already exists message
	                document.getElementById("errorTest").style.visibility = "hidden";
	                document.getElementById("successTest").style.visibility = "visible";
	                
	                /*var display = document.getElementById("display").innerHTML;
	                document.getElementById("display").innerHTML = output + display;*/
				}
				
				//unsuccessful message
				else {
					document.getElementById("successTest").style.visibility = "hidden";
					document.getElementById("errorTest").style.visibility = "visible";
				}
			},
			
			//upon unsuccessful connection. 
			error:function() {
				alert("Well this is awkward...Connection Unsuccessful");
				console.log("Failure to connect");
			}
		});
		}
		//return a false statement to prevent the html form from sending a post request
		//all the actions need to happen on the same page without refreshing
		send = false;
		return send;
	}

</script>
</head>
<body class="page-index" data-spy="scroll" data-offset="60" data-target="#toc-scroll-target">

    <jsp:include page="/jsp/header.jsp" />
    <div class="container">
        <div class="row">
            <div class="span12">
                <div class="body-content">
                    <div class="section">
                        <div class="page-header">
                            <h4>Sign Up</h4>
                        </div>
                        <div class="row">
                            <%
                            	String name = null, role = null, state = null;
                            	Integer age = null;
                            	try {
                            		name = request.getParameter("name");
                            	} catch (Exception e) {
                            		name = null;
                            	}
                            	try {
                            		role = request.getParameter("role");
                            	} catch (Exception e) {
                            		role = null;
                            	}
                            	try {
                            		age = Integer.parseInt(request.getParameter("age"));
                            	} catch (Exception e) {
                            		age = null;
                            	}
                            	try {
                            		state = request.getParameter("state");
                            	} catch (Exception e) {
                            		state = null;
                            	}
                            %>
                            <jsp:include page="/html/signup-form.html" />
                        </div>
                        <jsp:include page="/html/footer.html" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
