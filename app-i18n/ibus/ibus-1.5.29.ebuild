# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit autotools bash-completion-r1 gnome3-utils python-r1 toolchain-funcs vala virtualx

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="https://github.com/ibus/ibus/wiki"

SRC_URI="https://github.com/ibus/ibus/releases/download/1.5.29/ibus-1.5.29.tar.gz -> ibus-1.5.29.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="X appindicator +emoji gtk2 +gtk3 +gtk4 +gui +introspection libnotify nls +python +unicode vala wayland"

REQUIRED_USE="
	appindicator? ( gtk3 )
	python? (
		${PYTHON_REQUIRED_USE}
		introspection
	)
	vala? ( introspection )
	X? ( gtk3 )
"
REQUIRED_USE+=" gtk3? ( wayland? ( introspection ) )" # bug 915359
DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.74.0:2
	gnome-base/dconf
	gnome-base/librsvg:2
	sys-apps/dbus[X?]
	X? (
		x11-libs/libX11
		>=x11-libs/libXfixes-6.0.0
	)
	appindicator? ( dev-libs/libdbusmenu[gtk3?] )
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	gtk4? ( gui-libs/gtk:4 )
	gui? (
		x11-libs/libX11
		x11-libs/libXi
	)
	introspection? ( dev-libs/gobject-introspection )
	libnotify? ( x11-libs/libnotify )
	nls? ( virtual/libintl )
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	)
	wayland? (
		dev-libs/wayland
		x11-libs/libxkbcommon
	)"
RDEPEND="${DEPEND}
	python? (
		gui? (
			x11-libs/gtk+:3[introspection]
		)
	)"
BDEPEND="
	$(vala_depend)
	dev-libs/glib:2
	virtual/pkgconfig
	x11-misc/xkeyboard-config
	emoji? (
		app-i18n/unicode-cldr
		app-i18n/unicode-emoji
	)
	nls? ( sys-devel/gettext )
	unicode? ( app-i18n/unicode-data )"
# Funtoo-specific: ibus-ime-backends is only available on Funtoo. It installs desired IME backends depending on the user's ime-backend-* profile
PDEPEND="app-i18n/ibus-ime-backends"

src_prepare() {
	vala_src_prepare --ignore-use
	if ! has_version 'x11-libs/gtk+:3[wayland]'; then
		touch ui/gtk3/panelbinding.vala \
			ui/gtk3/panel.vala \
			ui/gtk3/emojierapp.vala || die
	fi
	if ! use emoji; then
		touch \
			tools/main.vala \
			ui/gtk3/panel.vala || die
	fi
	if ! use appindicator; then
		touch ui/gtk3/panel.vala || die
	fi

	# for multiple Python implementations
	sed -i "s/^\(PYGOBJECT_DIR =\).*/\1/" bindings/Makefile.am || die
	# fix for parallel install
	sed -i "/^if ENABLE_PYTHON2/,/^endif/d" bindings/pygobject/Makefile.am || die
	# require user interaction
	sed -i "/^TESTS_C += ibus-\(compose\|keypress\)/d" src/tests/Makefile.am || die

	sed -i "/^bash_completion/d" tools/Makefile.am || die

	default
	eautoreconf
	xdg_environment_reset
}

src_configure() {
	local unicodedir="${EPREFIX}"/usr/share/unicode
	local python_conf=()
	if use python; then
		python_setup
		python_conf+=(
			$(use_enable gui setup)
			--with-python=${EPYTHON}
		)
	else
		python_conf+=( --disable-setup )
	fi

	local myconf=(
		$(use_enable X xim)
		$(use_enable appindicator)
		$(use_enable emoji emoji-dict)
		$(use_with emoji unicode-emoji-dir "${unicodedir}"/emoji)
		$(use_with emoji emoji-annotation-dir "${unicodedir}"/cldr/common/annotations)
		$(use_enable gtk2)
		$(use_enable gtk3)
		$(use_enable gtk4)
		$(use_enable gui ui)
		$(use_enable introspection)
		$(use_enable libnotify)
		$(use_enable nls)
		--disable-systemd-services
		--disable-tests
		$(use_enable unicode unicode-dict)
		$(use_with unicode ucd-dir "${EPREFIX}/usr/share/unicode-data")
		$(use_enable vala)
		$(use_enable wayland)
		"${python_conf[@]}"
	)
	econf "${myconf[@]}"
}

src_install() {
	default
	# Remove la files
	find "${ED}" -name '*.la' -delete || die

	# Remove stray python files generated by the build system
	find "${ED}" -name '*.pyc' -exec rm -f {} \; || die
	find "${ED}" -name '*.pyo' -exec rm -f {} \; || die

	if use python; then
		python_install() {
			emake -C bindings/pygobject \
				pyoverridesdir="$(${EPYTHON} -c 'import gi; print(gi._overridesdir)')" \
				DESTDIR="${D}" \
				install

			python_optimize
		}
		python_foreach_impl python_install
	fi

	keepdir /usr/share/ibus/engine

	newbashcomp tools/${PN}.bash ${PN}

	insinto /etc/X11/xinit/xinput.d
	newins xinput-${PN} ${PN}.conf
}

pkg_postinst() {
	use gtk2 && gnome3_query_immodules_gtk2
	use gtk3 && gnome3_update_immodules_cache_gtk3
	gnome3_icon_cache_update
	gnome3_schemas_update
	dconf update
}

pkg_postrm() {
	use gtk2 && gnome3_query_immodules_gtk2
	use gtk3 && gnome3_update_immodules_cache_gtk3
	gnome3_icon_cache_update
	gnome3_schemas_update
}