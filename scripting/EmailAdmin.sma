/***********************************************
EmailAdmin.sma
With this plugin ppl are able to conctact an admin via email ingame

(c) 2007 core | Greenberet :: green@corona-bytes.net

> commands:
	amx_email <text> 
		text + Username + Steamid will be sent to the admin
> cvars:
	amx_email_host
		your mailserver with port e.g. your.mailserver.com:25
	amx_email_admin
		email address of the admin e.g. green@corona-bytes.net
	amx_email_from
		email address you want to have as sender. this email address could be everything so it doesnt really have to exist.
				e.g.your_admin@server.com
	amx_email_subject
		email subject. I think i dont have to explain this

> Version 1.0
    Release

> modifiy this file like u want, but please give credits 
    and notify me about it.
***********************************************/

#include <amxmodx>
#include <sockets>

stock CVAR_HOST;
stock CVAR_ADMIN_MAIL;
stock CVAR_MAIL_FROM;
stock CVAR_SUBJECT;

public plugin_init()
{
	register_plugin( "[GG] Recover Password", "1.0", "~D4rkSiD3Rs~" );
	register_clcmd( "amx_email", "cmdEmail", _,  "<text> sends an email with ^"text^" to an admin" );
	
	CVAR_HOST = register_cvar( "amx_email_host", "mail.example.com:25" );
	CVAR_ADMIN_MAIL = register_cvar( "amx_email_admin", "example@gmail.com" );
	CVAR_MAIL_FROM = register_cvar( "amx_email_from", "support@geek-gamers.com" );
	CVAR_SUBJECT = register_cvar( "amx_email_subject", "[Geek~Gamers] Recover Password" );
}

public cmdEmail( id )
{
	static error, host[128], admin_mail[128],from[128], subject[128],text[600];

	read_args(text,599);

	//im abusing the variables host & from for username and steamid here, but, who cares^^
	get_user_name(id,host,127);
	get_user_authid(id,from,127);
	format(text,599,"%s^r^nSender: %s^r^nSteamID: %s",text,host,from);

	get_pcvar_string( CVAR_HOST, host, 127 );
	get_pcvar_string( CVAR_ADMIN_MAIL, admin_mail, 127 );
	get_pcvar_string( CVAR_MAIL_FROM, from, 127 );
	get_pcvar_string( CVAR_SUBJECT, subject, 127 );

	//im using the error variable here for the port, dont waste resources ;)
	error = strfind(host,":");
	if( error == -1 )
		error = 25;
	else
	{
		host[error] = 0;
		error = str_to_num(host[error+1]);
	}
	
	error = sendMail( host, error, admin_mail, from, subject, text );

	if( error )
		client_print( id, print_notify, "Error on sending mail: error %i", error );
		
	return 1;

}

sendMail( server[], port, to[], from[], subject[], text[] )
{
	static buff[1024], socket, error, len;
	
	socket = socket_open( server , port, SOCKET_TCP, error );
	if( error ) 
		return error;
	
	// Always be polite and say helo
	len = formatex( buff, 1023, "HELO Greenberets_Email_AMXX_CLIENT^r^n" );
	socket_send( socket, buff, len );
	while(socket_is_readable( socket )) socket_recv( socket, buff, 1023);
	
	// Now tell the server from which email address you want to sent the email
	len = formatex( buff, 1023, "MAIL FROM:<%s>^r^n", from );
	socket_send( socket, buff, len );
	while(socket_is_readable( socket )) socket_recv( socket, buff, 1023);
	
	// tell the mailserver the email address of the admin. 
	// you can add more admins if you make more "RCPT TO:<%s>^r^n" lines
	len = formatex( buff, 1023, "RCPT TO:<%s>^r^n", to );
	socket_send( socket, buff, len );
	while(socket_is_readable( socket )) socket_recv( socket, buff, 1023);
	
	// Begin the DATA segment
	len = formatex( buff, 1023, "DATA^r^n" );
	socket_send( socket, buff, len );
	while(socket_is_readable( socket )) socket_recv( socket, buff, 1023);
	
	// subject and email text
	len = formatex( buff, 1023, "SUBJECT: %s^r^nFrom:<%s>^r^nTo:<%s>^r^n%s^r^n.^r^n", subject,from,to, text );
	socket_send( socket, buff, len );
	while(socket_is_readable( socket )) socket_recv( socket, buff, 1023);
	
	//quit the conversation with the server
	len = formatex( buff, 1023, "QUIT" );
	socket_send( socket, buff, len );
	while(socket_is_readable( socket )) socket_recv( socket, buff, 1023);
	
	socket_close(socket);
	
	return 0;
}