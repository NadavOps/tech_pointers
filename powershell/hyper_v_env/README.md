The Lab Contains 5 Machines:
4 Servers:
ReverseProxy   172.16.0.2
WEBServer      172.16.0.3
LinuxClient    172.16.0.4
WindowsClient  172.16.0.5

ReverseProxy:
        - Test.com – Reverse proxy to https://ynet.co.il with a self signed server cert
		
        - Test-client.com – Reverse proxy to https://ynet.co.il with a self signed server cert and client cert inforcment;
          that means I cannot access the url without adding the client-cert to the browser.
		  
        - Test-docker.com – Reverse proxy to a local mattermost container , also with client cert.

	- web.com - reverse proxy to the lan webserver mattermost service

