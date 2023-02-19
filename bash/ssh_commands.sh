# https://www.nixcraft.com/t/client-loop-send-disconnect-broken-pipe/2708/4
# https://github.com/microsoft/WSL/issues/7966
ssh -o TCPKeepAlive=yes -o ServerAliveCountMax=20 -o ServerAliveInterval=15 my-user-name@my-server-domain-name-here