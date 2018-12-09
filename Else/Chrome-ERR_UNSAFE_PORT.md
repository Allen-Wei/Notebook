
Question: 
ʹ��Chrome�� `http://my-server-address:87` ʱ, Chrome����ʾ���������µĴ���:
`Error 312 (net::ERR_UNSAFE_PORT): Unknown error.`

Answer: 
�һ�Chrome=>Properties, Ȼ���ڿ�ݷ�ʽ��׷�� `--explicitly-allowed-ports=xxx`.
����
`C:\Documents and Settings\User\Local Settings\Application Data\Google\Chrome\Application\chrome.exe --explicitly-allowed-ports=6666`

������Դ: [Google](http://www.google.com/support/forum/p/Chrome/thread?tid=7512620ef6d830c3&hl=en)

�����ժ��: [StackOverflow](http://superuser.com/questions/188006/how-to-fix-err-unsafe-port-error-on-chrome-when-browsing-to-unsafe-ports)

Note: 

Question: 
Some ports generate an error when browsing to them via Chrome (see this related question). Which ports are considered safe, and which are unsafe by default?

Answer: 

* 1,    // tcpmux
* 7,    // echo
* 9,    // discard
* 11,   // systat
* 13,   // daytime
* 15,   // netstat
* 17,   // qotd
* 19,   // chargen
* 20,   // ftp data
* 21,   // ftp access
* 22,   // ssh
* 23,   // telnet
* 25,   // smtp
* 37,   // time
* 42,   // name
* 43,   // nicname
* 53,   // domain
* 77,   // priv-rjs
* 79,   // finger
* 87,   // ttylink
* 95,   // supdup
* 101,  // hostriame
* 102,  // iso-tsap
* 103,  // gppitnp
* 104,  // acr-nema
* 109,  // pop2
* 110,  // pop3
* 111,  // sunrpc
* 113,  // auth
* 115,  // sftp
* 117,  // uucp-path
* 119,  // nntp
* 123,  // NTP
* 135,  // loc-srv /epmap
* 139,  // netbios
* 143,  // imap2
* 179,  // BGP
* 389,  // ldap
* 465,  // smtp+ssl
* 512,  // print / exec
* 513,  // login
* 514,  // shell
* 515,  // printer
* 526,  // tempo
* 530,  // courier
* 531,  // chat
* 532,  // netnews
* 540,  // uucp
* 556,  // remotefs
* 563,  // nntp+ssl
* 587,  // stmp?
* 601,  // ??
* 636,  // ldap+ssl
* 993,  // ldap+ssl
* 995,  // pop3+ssl
* 2049, // nfs
* 3659, // apple-sasl / PasswordServer
* 4045, // lockd
* 6000, // X11
* 6665, // Alternate IRC [Apple addition]
* 6666, // Alternate IRC [Apple addition]
* 6667, // Standard IRC [Apple addition]
* 6668, // Alternate IRC [Apple addition]
* 6669, // Alternate IRC [Apple addition]

Ҳ����˵Chrome���ǵ���ȫ��, ���϶˿ں�Chrome����һЩ����, �ͳ�������������.

������Դ: [StackOverflow](http://superuser.com/questions/188058/which-ports-are-considered-unsafe-on-chrome)
Դ��: [Chromium](https://src.chromium.org/viewvc/chrome/trunk/src/net/base/net_util.cc?view=markup)
