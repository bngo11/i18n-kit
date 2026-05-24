# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit desktop xdg-utils

DESCRIPTION="Vietnamese Bamboo engine for IBus"
HOMEPAGE="https://github.com/BambooEngine/ibus-bamboo"

SRC_URI="https://github.com/BambooEngine/ibus-bamboo/tarball/49e03d7a36b8a8b796950c158b545af8cf9707d4 -> ibus-bamboo-0.8.5-49e03d7.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

RDEPEND="app-i18n/ibus"
DEPEND="${RDEPEND}
	x11-libs/libX11
	x11-libs/libXtst"
BDEPEND="sys-devel/make
	dev-lang/go"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/BambooEngine-ibus-bamboo-* "${S}"
}

src_prepare() {
	# Conditionally apply patch for version 0.8.1 because
	# the developer messed up the makefile and make install
	# doesn't run as a result
	if [ "${PV}" == "0.8.1" ]; then
		PATCHES+=( "${FILESDIR}"/${P}-install.patch )
	fi
	default
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}