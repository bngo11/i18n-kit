# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools vala virtualx

DESCRIPTION="GObject-based library to deal with Japanese kana-to-kanji conversion method"
HOMEPAGE="https://github.com/ueno/libskk"
SRC_URI="https://github.com/ueno/libskk/releases/download/1.0.5/libskk-1.0.5.tar.xz -> libskk-1.0.5.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="+introspection nls static-libs"

RDEPEND="dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	x11-libs/libxkbcommon
	introspection? ( dev-libs/gobject-introspection )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}"
BDEPEND="$(vala_depend)
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	vala_src_prepare
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable introspection) \
		$(use_enable nls) \
		$(use_enable static-libs static)
}

src_test() {
	export GSETTINGS_BACKEND="memory"
	virtx emake check
}

src_install() {
	default
	use static-libs || find "${ED}" -name '*.la' -delete || die
}
