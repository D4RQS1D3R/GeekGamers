#include <amxmodx>
#include <sockets>
#include <amxmail>

#define PLUGIN "Amx Mail"
#define VERSION "0.1.0"
#define AUTHOR "PomanoB"

#define MAX_CONNECTIONS 3

#define MAIL_TIMEOUT 10.0

//#define MAIL_DEBUG

enum mailStatus
{
	mail_status_send,
	mail_status_quit
}

new g_sockets[MAX_CONNECTIONS]
new mailStatus:g_status[MAX_CONNECTIONS]

new Array:g_mailData[MAX_CONNECTIONS]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	set_task(1.0, "recvTask", _, _, _, "b")
	
	new i
	for (i = 0; i < MAX_CONNECTIONS; i++)
		g_mailData[i] = ArrayCreate(512, 32)

}

public plugin_natives()
{
	register_library("amxmail")
	
	register_native("smtp_connect","_smtp_connect");
	register_native("smtp_auth","_smtp_auth");
	register_native("smtp_send","_smtp_send");
	register_native("smtp_quit","_smtp_quit");
}

public _smtp_connect(plugin, params)
{
	new i, error, server[32]
	
	for (i = 0; i < MAX_CONNECTIONS; i ++)
	{
		if (!g_sockets[i])
			break
	}
	if (i == MAX_CONNECTIONS)
		return -1
	
	get_string(1, server, charsmax(server))
	g_sockets[i] = socket_open(server, get_param(2), SOCKET_TCP, error)
	
	if (error)
	{
		g_sockets[i] = 0
		return -1
	}	
	return i
}

public _smtp_auth(plugin, params)
{
	new socket, username[64], password[64], data[512]
	
	socket = get_param(1)
	get_string(2, username, charsmax(username))
	get_string(3, password, charsmax(password))
	
	ArrayPushString(g_mailData[socket], "EHLO AmxMailer^r^n")
	ArrayPushString(g_mailData[socket], "AUTH LOGIN^r^n")
	
	base64encode(username, data)
	add(data, charsmax(data), "^r^n")
	ArrayPushString(g_mailData[socket], data)
	
	base64encode(password, data)
	add(data, charsmax(data), "^r^n")
	ArrayPushString(g_mailData[socket], data)
	
	g_status[socket] = mail_status_send	
	return 0
}

public _smtp_send(plugin, params)
{
	new socket, from[64], to[64], subject[64], mail[512], addHeaders[64], data[512]
	
	socket = get_param(1)
	get_string(2, from, charsmax(from))
	get_string(3, to, charsmax(to))
	get_string(4, subject, charsmax(subject))
	get_string(5, mail, charsmax(mail))
	get_string(6, addHeaders, charsmax(addHeaders))
	
	formatex(data, charsmax(data), "MAIL FROM: %s^r^n", from)
	ArrayPushString(g_mailData[socket], data)
	
	formatex(data, charsmax(data), "RCPT TO: %s^r^n", to)
	ArrayPushString(g_mailData[socket], data)
	
	formatex(data, charsmax(data), "DATA^r^n")
	ArrayPushString(g_mailData[socket], data)
	
	
	formatex(data, charsmax(data), "To: %s^r^nFrom: %s^r^nSubject: %s^r^n",
		to, from, subject)
	if (strlen(addHeaders))
		add(data, charsmax(data), addHeaders)
	format(data, charsmax(data), "%s^r^n%s^r^n.^r^n", data, mail)	
	ArrayPushString(g_mailData[socket], data)
}

public _smtp_quit(plugin, params)
{
	ArrayPushString(g_mailData[get_param(1)], "QUIT^r^n")
}

public base64encode(str[], outStr[])
{
	static const base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	new index1, index2, byte, mul, ch, out
	new len
	
	len = strlen(str)
	
	while (len--)
	{
		byte = str[ch++]
		index1 = index2|((byte>>(1+mul)*2)&0x3F)
		index2 = (byte<<(2 - mul)*2)&0x3F
		outStr[out++] = base64[index1]
		if (mul++ == 2)
		{
			outStr[out++] = base64[index2]
			mul = index2 = 0
		}
	}
	
	if (mul != 0)
	{
		outStr[out++] = base64[index2]
	
		while (3 - mul++)
			outStr[out++] = '='
	}

	outStr[out] = 0
	
}

public recvTask()
{
	static i, socket, data[512], replyCode
	static Float:lastDataRecv[MAX_CONNECTIONS], curDataNumber[MAX_CONNECTIONS]
	
	for(i = 0; i < MAX_CONNECTIONS; i++)
	{
		socket = g_sockets[i]
		if (socket)
		{
		
			if (socket_change(socket, 1))
			{
				lastDataRecv[i] = get_gametime()
				setc(data, charsmax(data), 0)
				socket_recv(socket, data, charsmax(data))
#if defined MAIL_DEBUG				
				log_amx("<-^n%s", data)
#endif				
				replyCode = str_to_num(data)
				switch (replyCode)
				{
					case 220, 250, 334, 235, 354:
					{
						if (g_status[i] == mail_status_send)
						{
							ArrayGetString(
								g_mailData[i], 
								curDataNumber[i],
								data, charsmax(data))
							
							curDataNumber[i]++ 
#if defined MAIL_DEBUG
							log_amx("->^n%s", data)
#endif							
							socket_send(socket, data, 0)
						}
						
					}
					case 221:
					{
						closeSocket(i)
					}
					default:
					{
						log_amx("[AMXX MAIL] Socket %d error: %s", i, data)
						closeSocket(i)
					}
				}
			}
			else
			if (lastDataRecv[i] + MAIL_TIMEOUT < get_gametime())
			{
				log_amx("[AMXX MAIL] Socket %d timeout!", i)
				closeSocket(i)
				
			}
		}
		else if (curDataNumber[i])
				curDataNumber[i] = 0
	}
}

public closeSocket(i)
{
	socket_close(g_sockets[i])
	ArrayClear(g_mailData[i])
	g_sockets[i] = 0
#if defined MAIL_DEBUG	
	log_amx("Socket %d closed", i)
#endif
}

public plugin_end()
{
	new i
	for (i = 0; i < MAX_CONNECTIONS; i++)
	{
		if (g_sockets[i])
			closeSocket(i)
			
		ArrayDestroy(g_mailData[i])	
	}
}
