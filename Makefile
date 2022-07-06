all: trafficserver

.PHONY: trafficserver
trafficserver:
	$(MAKE) -C "trafficserver"

clean:
	$(MAKE) -C "trafficserver" clean
