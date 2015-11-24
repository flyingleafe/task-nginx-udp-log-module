CUR_DIR    := $(shell pwd)
MODULE_DIR := $(CUR_DIR)/src
NGX_DIR    := $(CUR_DIR)/nginx
CONF_DIR   := $(CUR_DIR)/conf
LOG_DIR    := $(CUR_DIR)/logs

NGX_MAKEFILE   := $(NGX_DIR)/Makefile
NGX_OBJS_DIR   := $(NGX_DIR)/objs
NGX_EXECUTABLE := $(NGX_OBJS_DIR)/nginx
CONF_FILE      := $(CONF_DIR)/nginx.conf
ERROR_LOG      := $(LOG_DIR)/error.log
ACCESS_LOG     := $(LOG_DIR)/access.log
PID_FILE       := $(LOG_DIR)/nginx.pid
LOCK_FILE      := $(LOG_DIR)/nginx.lock

# Port for nginx to listen on. Here just for convenience
PORT := 8080

.PHONY: all config configure clean clean_objs ngx_start ngx_stop

all: $(CONF_FILE) $(NGX_EXECUTABLE)

configure: $(NGX_MAKEFILE)
config: $(CONF_FILE)

$(NGX_MAKEFILE): $(LOG_DIR)
	cd $(NGX_DIR); \
	./auto/configure --with-debug \
		--add-module=$(MODULE_DIR) \
		--conf-path=$(CONF_FILE) \
		--error-log-path=$(ERROR_LOG) \
		--http-log-path=$(ACCESS_LOG) \
		--pid-path=$(PID_FILE) \
		--lock-path=$(LOCK_FILE)

$(NGX_EXECUTABLE): $(NGX_MAKEFILE)
	cd $(NGX_DIR) && $(MAKE)

$(LOG_DIR):
	mkdir -p $(LOG_DIR)

$(CONF_FILE): $(CONF_FILE).tpl
	sed -e "s|%%NGINX_DIR%%|$(NGX_DIR)|g" \
		-e "s|%%CUR_DIR%%|$(CUR_DIR)|g" \
		-e "s|%%PORT%%|$(PORT)|g" \
		-e "s|%%ERROR_LOG%%|$(ERROR_LOG)|g" \
		< $< > $(CONF_FILE)

clean:
	if [ -a $(NGX_MAKEFILE) ] ; then \
		cd $(NGX_DIR) && $(MAKE) clean; \
	fi
	rm -rf $(CONF_FILE) $(LOG_DIR)

clean_objs:
	find $(NGX_OBJS_DIR) -name "**.o" -exec rm -f {} \;
	rm -f $(NGX_EXECUTABLE)

ngx_start:
	@if [ ! -a $(PID_FILE) ] ; then \
		$(NGX_EXECUTABLE) && echo "Running nginx on port $(PORT)"; \
	else \
		echo "Nginx is already running"; \
	fi

ngx_stop:
	@if [ -a $(PID_FILE) ] ; then \
		$(NGX_EXECUTABLE) -s stop; \
	else \
		echo "Nginx is not running"; \
	fi
