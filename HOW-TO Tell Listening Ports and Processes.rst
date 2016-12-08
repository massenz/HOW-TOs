# HOW-TO Tell which process is using a port

TL;dr:

    lsof -i :<port number>

Longer version from [Debian Administration article for lsof](http://www.debian-administration.org/article/How_to_find_out_which_process_is_listening_upon_a_port):

Also useful an [introduction to port scanning](https://debian-administration.org/article/178/An_introduction_to_port_scanning_with_nmap) using `nmap`; again, the TL;dr version is:

    nmap <host or IP>
