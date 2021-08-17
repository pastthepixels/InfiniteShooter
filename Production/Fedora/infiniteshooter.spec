Name:	 InfiniteShooter
Version: 2
Release: 2%{?dist}
Summary: A shooter game

License: GPLv2
Source0: infiniteshooter
Source1: InfiniteShooter.desktop
BuildArch: x86_64
Prefix: /opt

%description
A shooter game.

%install
mkdir -p -m0755 %{buildroot}/opt
mkdir -p %{buildroot}/usr/share/applications
cp -r %{SOURCE0} %{buildroot}/opt
cp -r %{SOURCE1} %{buildroot}/usr/share/applications
#install -p -m 755 %{SOURCE0} %{buildroot}

%files
/opt/infiniteshooter
/usr/share/applications/InfiniteShooter.desktop

%changelog
