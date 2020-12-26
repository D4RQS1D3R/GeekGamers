#if defined AMX_MAIL_INCLUDED
  #endinput
#endif
#define AMX_MAIL_INCLUDED

#if AMXX_VERSION_NUM >= 175
 #pragma reqlib amxmail
 #if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib amxmail
 #endif
#else
 #pragma library amxmail
#endif

/*
* Connect to an SMTP server
*
* Server - the server address
* Port - the server port
*
* If successful, the function returns the identifier of the server
* It should be used in the first parameter of the remaining functions
*
* In case of failure, returns -1
*
*/
native smtp_connect(server[], port);


/*
* Login to the SMTP server
*
* Socket - server ID
* Username - user name (for example name@mail.hu)
* Password - the password
*
*/
native smtp_auth(socket, username[], password[]);


/*
* Send a letter
*
* Socket - server ID
* From - from whom a letter (for most servers must match the name of the user)
* To - to whom the letter
* Subject - the subject line
* Mail - the contents of the letter
* AddHeaders - additional headers (eg Reply-To :)
*
*/
native smtp_send(socket, from[], to[], subject[], mail[], addHeaders[]);


/*
* Disconnect from the server
*
* Socket - server ID
*/
native smtp_quit(socket);

