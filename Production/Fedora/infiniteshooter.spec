Name:	 InfiniteShooter
Version: 2
URL:     https://github.com/pastthepixels/InfiniteShooter
Release: 2%{?dist}
Summary: A shooter game

License: GPLv2
Source0: https://github.com/pastthepixels/InfiniteShooter/raw/godot/Production/sources.tar.gz
BuildArch: x86_64

%description
A shooter game.

%install
mkdir -p -m0755 %{buildroot}/opt
mkdir -p %{buildroot}/usr/share/applications

cp -r %{_builddir}/sources/infiniteshooter %{buildroot}/opt

cp -r %{_builddir}/sources/InfiniteShooter.desktop %{buildroot}/usr/share/applications

%files
/opt/infiniteshooter
/usr/share/applications/InfiniteShooter.desktop
