PROJECT = OPENIVI001.HomeScreen
INSTALL_FILES = images js icon.png index.html
WRT_FILES = DNA_common css icon.png index.html setup config.xml images js manifest.json README.md
VERSION := 0.0.1
PACKAGE = $(PROJECT)-$(VERSION)

SEND := ~/send

ifndef TIZEN_IP
TIZEN_IP=TizenVTC
endif

dev: clean dev-common
	zip -r $(PROJECT).wgt config.xml css icon.png index.html js images DNA_common

wgtPkg: common
	#cp -rf ../DNA_common .
	zip -r $(PROJECT).wgt config.xml css icon.png index.html js images DNA_common

config:
	scp setup/weston.ini root@$(TIZEN_IP):/etc/xdg/weston/

$(PROJECT).wgt : dev

wgt:
	zip -r $(PROJECT).wgt $(WRT_FILES)

kill.xwalk:
	ssh root@$(TIZEN_IP) "pkill xwalk"

kill.feb1:
	ssh app@$(TIZEN_IP) "pkgcmd -k OpenIVI.HomeScreen"

run: install
	ssh app@$(TIZEN_IP) "export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/5000/dbus/user_bus_socket' && xwalkctl | egrep -e 'Home Screen' | awk '{print $1}' | xargs --no-run-if-empty xwalk-launcher -d "

run.feb1: install.feb1
	ssh app@$(TIZEN_IP) "app_launcher -s OpenIVI.HomeScreen -d "

install.feb1: deploy
ifndef OBS
	-ssh app@$(TIZEN_IP) "pkgcmd -u -n OpenIVI.HomeScreen -q"
	ssh app@$(TIZEN_IP) "pkgcmd -i -t wgt -p /home/app/OpenIVI.HomeScreen.wgt -q"
endif

install: deploy
ifndef OBS
	ssh app@$(TIZEN_IP) "export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/5000/dbus/user_bus_socket' && xwalkctl | egrep -e 'Home Screen' | awk '{print $1}' | xargs --no-run-if-empty xwalkctl -u"
	ssh app@$(TIZEN_IP) "export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/5000/dbus/user_bus_socket' && xwalkctl -i /home/app/DNA_HomeScreen.wgt"
endif

$(PROJECT).wgt : wgt

deploy: dev
ifndef OBS
	scp $(PROJECT).wgt app@$(TIZEN_IP):/home/app
endif

all:
	@echo "Nothing to build"


clean:
	-rm $(PROJECT).wgt
	-rm -rf DNA_common


boxcheck: tizen-release
	ssh root@$(TIZEN_IP) "cat /etc/tizen-release" | diff tizen-release - ; if [ $$? -ne 0 ] ; then tput setaf 1 ; echo "tizen-release version not correct"; tput sgr0 ;exit 1 ; fi

install_obs:
	mkdir -p ${DESTDIR}/opt/usr/apps/.preinstallWidgets
	cp -r JLRPOCX00.HomeScreen.wgt ${DESTDIR}/opt/usr/apps/.preinstallWidgets/

common: /opt/usr/apps/openivi-common-apps
	cp -r /opt/usr/apps/openivi-common-apps DNA_common

/opt/usr/apps/openivi-common-apps:
	@echo "Please install Common Assets"
	exit 1

dev-common: ../openivi-common-app
	cp -rf ../openivi-common-app ./DNA_common
	rm -rf DNA_common/.git

../openivi-common-app:
	#@echo "Please checkout Common Assets"
	#exit 1
	git clone  git@github.com:konsulko/openivi-common-app.git ../openivi-common-app
