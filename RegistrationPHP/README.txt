Registration Page - Sean McLellan
---------------------------------

Installation:

This project was built using XAMPP. To get it to work, paste the contents of the htdocs folders directly into your
web folder for sites (in XAMPP this would be htdocs). Run the contents of the SQLProcedures file on your MySQL 
database management system. If you wish to use another RDMS you will need to adapt the contents of this file to 
use the appropriate syntax.

Description:

This is an implementation of a functioning registration page. The locked page will redirect to a no access page
when the user is not logged in. The user will attempt to login on the index page. Users will try to register an 
account on the registration page, if the creation is successful a link will be shown to the user to activate the
account. You can adjust the implementation to instead send an email containing the link directly to the user for
activation through the use of PHP functions like mailto(), keep in mind that it will not send emails from a local
server without additional setup.

