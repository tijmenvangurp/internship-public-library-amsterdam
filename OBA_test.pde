import netscape.javascript.*;

import de.bezier.data.sql.*;
MySQL mysql;

// Import Phidget Library
import com.phidgets.*;
import com.phidgets.event.*;

// Variables
PFont font;

String rfidtag ="test";
int iduser;
int[] rfid_serial = new int[3];
RFIDPhidget rfid[] = new RFIDPhidget[rfid_serial.length]; // Array of #x RFID readers

void setup() {
  rfid_serial[0] = 13726; //user
  rfid_serial[1] = 18514; // book
    rfid_serial[2] = 17836; //show data on screen
  size(100, 100);
 

 // SQL setup
  String host     = "localhost"; // our own server on computer 192.168.1.100
//  String host     = "localhost"; // our own server on computer 192.168.1.100
  String user     = "tijmen";
  String pass     = "konijn";
  String database = "oba1";
  mysql = new MySQL(this, host, database, user, pass);
  if(mysql.connect()) {
    println("Connected");
    mysql.close();
  }

// Load RFID readers
  for(int i = 0; i < rfid_serial.length; i++) {
    try {
      rfid[i] = new RFIDPhidget();
      rfid[i].open(rfid_serial[i]); // open the x'th RFID reader with it's unique serial number
      // Attach an Add listener, so that we know when an Phidget is attached.
      rfid[i].addAttachListener(new AttachListener() {
          public void attached(AttachEvent ae)
          {
            try
            {
              ((RFIDPhidget)ae.getSource()).setLEDOn(false);
              ((RFIDPhidget)ae.getSource()).setAntennaOn(true);
            }
            catch (PhidgetException ex) {
            }
            println("attachment of " + ae);
          }
        }
      );

// Attach an Detach listener, to catch an exception when an RFID reader is disconnected
      rfid[i].addDetachListener(new DetachListener()
        {
          public void detached(DetachEvent ae) {
            System.out.println("detachment of " + ae);
          }
        }
      );


// Add an TAG listener, which inserts a new scan in the database and perhaps even a new user
      rfid[i].addTagGainListener(new TagGainListener()
        {
          public void tagGained(TagGainEvent oe)
          {
            System.out.println(oe);
            try {
              if(13726 == ((RFIDPhidget)oe.getSource()).getSerialNumber()) {                  
              doPrint(oe.getValue().toUpperCase());
              updatevisibility_user(oe.getValue().toUpperCase());
              }
              
              if(18541 == ((RFIDPhidget)oe.getSource()).getSerialNumber()) {                  
              doPrint(oe.getValue().toUpperCase());
              updatevisibility_book(oe.getValue().toUpperCase());
              }
              if(17836 == ((RFIDPhidget)oe.getSource()).getSerialNumber()) {                  
               show_story(oe.getValue().toUpperCase());
              }
              ((RFIDPhidget)oe.getSource()).setLEDOn(true);
            } catch (PhidgetException ex) {
              println("uhm");
            }
          }
        }
      );
// Add an TAG Lost listener, to do something when the TAG is lost.
rfid[i].addTagLossListener(new TagLossListener()
        {
          public void tagLost(TagLossEvent oe)
          {
            
            System.out.println(oe);
            
            try {
              
              if(13726 == ((RFIDPhidget)oe.getSource()).getSerialNumber()) {
              clearvisibility_user(oe.getValue().toUpperCase());      
            
             }
               if(18541 == ((RFIDPhidget)oe.getSource()).getSerialNumber()) {                  
                 clearvisibility_book(oe.getValue().toUpperCase());
              }
              
              
              
              ((RFIDPhidget)oe.getSource()).setLEDOn(false);
            } catch (PhidgetException ex) {
              println("uhm");
            }
          }
        }
      );
    } catch (PhidgetException ex) {
      System.out.println(ex);
    }
  }
}

// Not much happening here yet, but needs to display the scan and the RFID readers that are attached in a nice way?
void draw() {
  
}

void doPrint(String tag) {
  
    //tag = "xx" + tag.substring(2, 10);
     tag = "xx" + tag.substring(0,10);     
    //link("http://localhost/oba/oba1/content.php?rfid=" + tag, "_same");
       }
   
void updatevisibility_book (String tag) {
  if(mysql.connect()) {
    tag = "xx" + tag.substring(0, 10);
    println("change visibility of book: " + tag);
    mysql.execute("UPDATE `books` SET `visible`='1' WHERE `rfid`='"+tag+"'");
    mysql.close();
  } else { println("Connection failed!"); }
}

void clearvisibility_book (String tag) {
  if(mysql.connect()) {
    tag = "xx" + tag.substring(0, 10);
    println("change visibility of book: " + tag);
    mysql.execute("UPDATE `books` SET `visible`='0' WHERE `rfid`='"+tag+"'");
   println("UPDATE `books` SET `visible`='0' WHERE `rfid`='"+tag+"'");
    mysql.close();
  } else { println("Connection failed!"); }
}
void updatevisibility_user(String tag) {
  boolean newuser = false;
  if(mysql.connect()) {
    tag = "xx" + tag.substring(0, 10);
    println("change visibility of user: " + tag);
    mysql.query("SELECT * FROM personal_info ");
  while (mysql.next())
        {
            String s = mysql.getString("rfid");
            int n = mysql.getInt("id");
            println(s + "   " + n);
            print("tag= ");print(tag); print("  database= ");print(s);
            boolean test =(tag.equals(s));
            println(test);
            if(test==true){
            println("test is true");
           newuser = true;
                        }
                 println(newuser);
               }
    if(newuser==true){    
    mysql.execute("UPDATE `personal_info` SET `visible`='1' WHERE `rfid`='"+tag+"'");
    mysql.close();
  } else { println("This is a NEW USER!"); }}
  if(newuser==false){
    mysql.execute("INSERT INTO `personal_info`(rfid, url_picture, picture_visible, name, profession, profesion_visible, visible, new_user) VALUES('"+tag+"','images/profilepictures/placeholder.png',1,'Your Name','Your profession',1,1,1) ");
    mysql.close();
  }
}

void clearvisibility_user (String tag) {
  if(mysql.connect()) {
    tag = "xx" + tag.substring(0, 10);
    println("change visibility of user: " + tag);
    mysql.execute("UPDATE `personal_info` SET `visible`='0' WHERE `rfid`='"+tag+"'");
   println("UPDATE `books` SET `visible`='0' WHERE `rfid`='"+tag+"'");
    mysql.close();
  } else { println("Connection failed!"); }
}

void show_story(String tag) {
  
  if(mysql.connect()) {
    tag = "xx" + tag.substring(0, 10);
    println("change visibility of SCREEEN" + tag);
    mysql.query("SELECT * FROM personal_info WHERE `rfid`='"+tag+"'");
    mysql.next();
        int iduser = mysql.getInt("id");
        println("this is the ID from the usere we want to show data on the screen: ");
        println(iduser);
       mysql.execute("UPDATE `book_story` SET `on_screen_1`='0'"); 
      mysql.execute("UPDATE `book_story` SET `on_screen_1`='1' WHERE `user_id`='"+iduser+"'AND show_story= 1");
                           
    println(iduser);
    mysql.close();
    
  }
}



