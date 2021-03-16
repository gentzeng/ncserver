install:
	mkdir -p ~/.ncserver
	cp ./ncs.sh ~/.ncserver/ncs.sh
	sudo ln -s ~/.ncserver/ncs.sh /usr/local/bin/ncs
installforce:
	mkdir -p ~/.ncserver
	cp -f ./ncs.sh ~/.ncserver/ncs.sh
	sudo ln -s ~/.ncserver/ncs.sh /usr/local/bin/ncs
