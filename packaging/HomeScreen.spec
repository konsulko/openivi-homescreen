Name:       HomeScreen
Summary:    An app launching application
Version:    0.0.1
Release:    1
Group:      Applications/System
License:    Apache 2.0
URL:        http://www.tizen.org
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  openivi-common-apps
BuildRequires:  zip
BuildRequires:  desktop-file-utils
Requires: pkgmgr
Requires: crosswalk
Requires: tizen-extensions-crosswalk
Requires: pkgmgr-server
Requires: model-config-ivi
Requires: tizen-middleware-units
Requires: tizen-platform-config

%description
A proof of concept pure html5 UI

%prep
%setup -q -n %{name}-%{version}

%build
make wgtPkg

%install
rm -rf %{buildroot}
make install_obs "OBS=1" DESTDIR="%{?buildroot}"
mkdir -p %{?buildroot}%{_bindir}
mkdir -p %{?buildroot}%{_unitdir_user}
mkdir -p %{?buildroot}%{_unitdir_user}/tizen-user-middleware.target.wants/
mkdir -p %{?buildroot}/home
mkdir -p %{?buildroot}/home/app
install -m 0755 systemd/DNA_launcher.sh %{?buildroot}%{_bindir}
install -m 0644 systemd/DNA_Homescreen* %{?buildroot}%{_unitdir_user}
install -m 0755 app_install.sh %{?buildroot}/home/app/
#install -m 0644 weston-genivi.ini %{?buildroot}/home/app/
ln -sf %{_unitdir_user}/DNA_Homescreen-launchpad-ready.path %{?buildroot}%{_unitdir_user}/tizen-user-middleware.target.wants/

%post
su app -c "pkgcmd -i -t wgt -p /opt/usr/apps/.preinstallWidgets/OpenIVI.HomeScreen.wgt -q"

%postun
su app -c "pkgcmd -u -n OpenIVI -q"

%files
%defattr(-,root,root,-)
/opt/usr/apps/.preinstallWidgets/OpenIVI.HomeScreen.wgt
/home/app/app_install.sh
#/home/app/weston-genivi.ini
%{_bindir}/DNA_launcher.sh
%{_unitdir_user}/DNA_Homescreen-launchpad-ready.path
%{_unitdir_user}/tizen-user-middleware.target.wants/DNA_Homescreen-launchpad-ready.path
%{_unitdir_user}/DNA_Homescreen.service
