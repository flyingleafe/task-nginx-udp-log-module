worker_processes  1;
error_log %%ERROR_LOG%% debug;

events {
    worker_connections  1024;
}

http {
    client_body_temp_path /tmp/client_body;
    fastcgi_temp_path /tmp/fastcgi_temp;
    proxy_temp_path /tmp/proxy_temp;
    scgi_temp_path /tmp/scgi_temp;
    uwsgi_temp_path /tmp/uwsgi_temp;    
 
    include       %%NGINX_DIR%%/conf/mime.types;
    default_type  application/octet-stream;

    sendfile           on;
    keepalive_timeout  65;

    server {
        listen       %%PORT%%;
        server_name  localhost;

        location = /style.css {
            root         %%CUR_DIR%%/html;   
            udp_logging  localhost;
        }

        location / {
            root        %%CUR_DIR%%/html;
            index       index.html index.htm;
            udp_logging localhost:60300;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   %%CUR_DIR%%/html;
        }
    }
}
