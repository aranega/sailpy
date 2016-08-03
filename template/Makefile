sourcePath:=$(shell pwd)
include $(shell bash $(sourcePath)/rpm/parseconfig.bash) # Naaaaasty hack
Appname:=$(shell basename $$(pwd))
prefix:=/usr
temp:=/tmp/fpm-jolla
sdkpath:=$(shell cat .sailpy-init)
dependencies:=$(shell for file in $(config_Requires);do echo "-d \""$${file}"\"";done;)
maintainer:=$(shell echo "$(config_Maintainer)")
license:=$(shell echo "$(config_License)")
url:=$(shell echo "$(config_URL)")
arch:=noarch
version:=$(config_Version)
iteration:=1
rpmname:=$(Appname)-$(version)-$(iteration).$(arch).rpm
ssh_user:=nemo
engine_user:=mersdk
jolla_usb_ip:=192.168.1.15
jolla_wifi_ip:=Jolla  # Put your jolla wifi ip here or pass it like this: 'make your_rule jolla_wifi_ip=xxx.xxx.xxx.xxx'
interactive:=
fpm:=fpm

all: clean build-tmp rpm

make-jolla-usb: build-tmp rpm send-jolla-usb
make-jolla-wifi: build-tmp rpm send-jolla-wifi
make-jolla-ap: build-tmp rpm send-jolla-ap
make-virt: build-tmp rpm send-virt

tmp-deps: requirements.txt
	rm -rf $(sourcePath)/tmp-deps
	$(sourcePath)/rpm/extract-deps.bash

build-tmp: tmp-deps .sailpy-init
	rm -rf $(temp)
	mkdir -p $(temp)/usr/share/applications
	mkdir -p $(temp)/usr/share/$(Appname)/src/
	mkdir -p $(temp)/usr/share/icons/hicolor/86x86/apps
	cp -ar $(sourcePath)/qml $(temp)/usr/share/$(Appname)
	cp -ar $(sourcePath)/src/* $(temp)/usr/share/$(Appname)/src
	cp -ar $(sourcePath)/pyPackages/* $(temp)/usr/share/$(Appname)/src/
	cp -ar $(sourcePath)/tmp-deps/* $(temp)/usr/share/$(Appname)/src/
	cp $(sourcePath)/data/$(Appname).desktop $(temp)/usr/share/applications/
	chmod a+r $(temp)/usr/share/applications/$(Appname).desktop
	cp -ar $(sourcePath)/data/appicon.png $(temp)/usr/share/icons/hicolor/86x86/apps/$(Appname).png

rpm: build-tmp
	cd $(temp);$(fpm) -f -s dir -t rpm \
		--description "`printf "$(config_description)"`" \
		--rpm-changelog $(sourcePath)/changelog.txt \
		--directories "/usr/share/$(Appname)" \
		--vendor ""\
		-v $(version) \
		--iteration $(iteration) \
		$(dependencies) \
		-p $(temp)/$(rpmname) \
		-n $(Appname) \
		-a $(arch) \
		-m $(maintainer) \
		$(interactive) \
		--url $(url) \
		--license $(license) \
		--prefix / * ; cp $(rpmname) $(sourcePath)

interactive-rpm: interactive:=-e
interactive-rpm: rpm

rpm-validation: rpm
	cat $(temp)/$(rpmname) | ssh -i '$(sdkpath)/vmshare/ssh/private_keys/engine/mersdk' -p2222 $(engine_user)@localhost \
		cat ">" /tmp/$(rpmname) "&&" \
		rpmvalidation.sh /tmp/$(rpmname) "&&" \
		rm /tmp/$(rpmname)

send-virt:
	cat $(temp)/$(rpmname) | ssh -i '$(sdkpath)/vmshare/ssh/private_keys/SailfishOS_Emulator/nemo' -p2223 $(ssh_user)@localhost \
		cat ">" /tmp/$(rpmname) "&&" \
		pkcon install-local -y /tmp/$(rpmname) "&&" \
		rm /tmp/$(rpmname)

send-only-virt:
		cat $(temp)/$(rpmname) | ssh -i '$(sdkpath)/vmshare/ssh/private_keys/SailfishOS_Emulator/nemo' -p2223 $(ssh_user)@localhost \
			cat ">" /tmp/$(rpmname)

send-jolla-wifi:
	cat $(temp)/$(rpmname) | ssh $(ssh_user)@$(jolla_wifi_ip) \
		cat ">" /tmp/$(rpmname) "&&" \
		pkcon install-local -y /tmp/$(rpmname) "&&" \
		rm /tmp/$(rpmname)

send-jolla-ap: jolla_wifi_ip:=192.168.1.1
send-jolla-ap:
	cat $(temp)/$(rpmname) | ssh $(ssh_user)@$(jolla_wifi_ip) \
		cat ">" /tmp/$(rpmname) "&&" \
		pkcon install-local -y /tmp/$(rpmname) "&&" \
		rm /tmp/$(rpmname)

send-jolla-usb:
	cat $(temp)/$(rpmname) | ssh $(ssh_user)@$(jolla_usb_ip) \
		cat ">" /tmp/$(rpmname) "&&" \
		pkcon install-local -y /tmp/$(rpmname) "&&" \
		rm /tmp/$(rpmname)

clean: .sailpy-init
	rm -rf $(temp)
	rm -rf $(builddir)
	rm -rf $(sourcePath)/$(rpmname)
	rm -rf $(sourcePath)/tmp-deps
