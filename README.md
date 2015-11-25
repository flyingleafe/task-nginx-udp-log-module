Nginx UPD Logger plugin
===
A simple plugin which logs incoming connections to UDP server.
### Configuration
All configuration is done via single directive: `udp_logging`. Example:
```
udp_logging   localhost:51535;
```
If no port is specified, default port `60228` is used:
```
udp_logging   localhost;
```
You can also turn logging off (for some specific location, for example):
```
udp_logging   off;
```
See the [configuration template](conf/nginx.conf.tpl) for better understanding.
### Log format
Plugin sends UDP packets in the following format:
```
<method_name>
<request_uri>
<crc32_of_uri>
```
Fields are separated by linefeed (`\n` on Unix system, `\r\n` on Windows).
For example,
```
GET
/index.html
ea224b42
```
### Building the plugin
To build and test the plugin, you should also have Nginx sources. Fortunately, they are included as a submodule.

After cloning this repo and `git submodule update` you can use `make` to build Nginx with this module included.

### Testing
To start test build of Nginx from your folder, run `make ngx_start`. Use `make ngx_stop` to stop it.

There is a small UDP server for testing included, written in Go. Usage:
```
./test_srv <port1> <port2> ... <portN>
```
This starts a server listening for `N` ports and printing log entries it gets to `stdout`.
