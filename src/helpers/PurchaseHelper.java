package helpers;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpSession;

public class PurchaseHelper {

    public static String purchaseCart(ShoppingCart cart, Integer uid) {
        Connection conn = null;
        Statement stmt = null;
        try {
            try {
                conn = HelperUtils.connect();
            } catch (Exception e) {
                return HelperUtils.printError("Internal Server Error. This shouldn't happen.");
            }
            stmt = conn.createStatement();
            for (int i = 0; i < cart.getProducts().size(); i++) {
                ProductWithCategoryName p = cart.getProducts().get(i);
                int quantity = cart.getQuantities().get(i);
                conn.setAutoCommit(false);
                String SQL_1 = "INSERT INTO cart_history (uid) VALUES (" + uid + ");";
                stmt.execute(SQL_1);
                // Gets latest inserted id. See this stackoverflow for more information http://stackoverflow.com/questions/2944297/postgresql-function-for-last-inserted-id
                String SQL_2 = "SELECT lastval();";
                ResultSet rs = stmt.executeQuery(SQL_2);
                rs.next();
                int cart_id = rs.getInt(1);
                String SQL_3 = "INSERT INTO sales (uid, pid, cart_id, quantity, price) VALUES(" + uid + ",'"
                      + p.getId() + "','" + cart_id + "','" + quantity + "', " + p.getPrice() + ");";
               stmt.execute(SQL_3);
               
               
               
                System.out.println("the first of ONE OF MY RETARDED QUERIES " + uid);
                String SQL_4 = "SELECT state FROM users WHERE users.id = " +uid;
                ResultSet stateR = stmt.executeQuery(SQL_4);
                System.out.println("AFTER RESULTSTATE STATER MADE");
           
                System.out.println("the STATES OF MY RETARDED QUERIES");
                int stateID;
                stateR.next();
                	stateID = stateR.getInt(1);
                String stateName = "SELECT name FROM states WHERE states.id = "+stateID;
                ResultSet productR = stmt.executeQuery(stateName);
                productR.next();
                String pname = productR.getString(1);
                
                String productString = "SELECT name FROM StateProducts WHERE StateProducts.pid ="+p.getId();
                ResultSet productName = stmt.executeQuery(productString);
                productName.next();
                String nameOfProduct = productName.getString(1);
                
              System.out.println("STATE ID " + stateID + "  -- STATE NAME   " + pname + "   PRODUCT -- " + nameOfProduct);  

              System.out.println("the INTESERTING RETARDEDA ADWARETARDED QUERIES");      
              
              
                String insertNewSales = "INSERT INTO newSales (stateID, product) VALUES('"  + stateID + "','"
                        + nameOfProduct + "');";
                stmt.execute(insertNewSales);
                
                
               
                conn.commit();
                conn.setAutoCommit(true);
            }
            cart.empty();
            return HelperUtils.printSuccess("Purchase successful!");
        } catch (SQLException e) {
            return HelperUtils.printError("Oops! Looks like the product you want to buy is no longer available...");
        } finally {
            try {
                stmt.close();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public static ShoppingCart obtainCartFromSession(HttpSession session) {
        ShoppingCart cart;
        try {
            cart = (ShoppingCart) session.getAttribute("cart");
            if (cart == null) {
                cart = new ShoppingCart();
            }
        } catch (Exception e) {
            cart = new ShoppingCart();
        }
        session.setAttribute("cart", cart);
        return cart;
    }

}