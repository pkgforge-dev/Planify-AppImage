#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	aspell                \
	cairo                 \
	chrono                \
	enchant               \
	evolution-data-server \
	gtksourceview5        \
	gxml                  \
	json-glib             \
	libadwaita            \
	libgee                \
	libgoa                \
	libical               \
	libportal             \
	libportal-gtk4        \
	libsecret             \
	libsoup3              \
	libspelling           \
	meson                 \
	pango                 \
	sqlite                \
	vala

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Building planify..."
echo "---------------------------------------------------------------"
git clone https://github.com/alainm23/planify.git ./planify && (
	cd ./planify

	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version

	# disable flathub network request
	git apply ../patches/*.patch

	meson setup build --prefix=/usr --buildtype=release
	meson compile -C build
	meson install -C build

	# archlinux does this for ease of typing the command
	# this also applies to the appimage when symlinked in PATH + ARGV0 launch
	ln -s io.github.alainm23.planify            /usr/bin/planify
	ln -s io.github.alainm23.planify.cli        /usr/bin/planify-cli
	ln -s io.github.alainm23.planify.quick-add  /usr/bin/planify-quick-add
)
