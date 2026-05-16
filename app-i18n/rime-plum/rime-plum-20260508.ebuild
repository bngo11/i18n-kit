# Distributed under the terms of the GNU General Public License v2
# Plum replaces brise, the old database package that many distributions currently use
EAPI="7"

inherit user

DESCRIPTION="Rime configuration manager and input schema repository"
HOMEPAGE="https://rime.im/ https://github.com/rime/plum"
SRC_URI="
	https://github.com/rime/plum/archive/b1be1969f914cc005add4090631b855db00c2591.tar.gz -> rime-plum-20260508.tar.gz
	https://github.com/rime/rime-bopomofo/archive/6085c9a38a4a728047862b33d67eee18aa86f3b9.tar.gz -> bopomofo.tar.gz
	https://github.com/rime/rime-cangjie/archive/d3ea6bf24e0c9cf593788210945226582bcb4bc9.tar.gz -> cangjie.tar.gz
	https://github.com/rime/rime-essay/archive/425cc5d152a84389b6fde0ed85929abbfdea401d.tar.gz -> essay.tar.gz
	https://github.com/rime/rime-luna-pinyin/archive/ba97605aa00b4a972c1bfcd705b957fcd90b192c.tar.gz -> luna-pinyin.tar.gz
	https://github.com/rime/rime-prelude/archive/082425ea0684bca36474415d4a0e8db9b016487e.tar.gz -> prelude.tar.gz
	https://github.com/rime/rime-quick/archive/82b95c7de8124dae27a8e6ee17ee9e991f4ec244.tar.gz -> quick.tar.gz
	https://github.com/rime/rime-stroke/archive/3a4b0f4013e2b4c14b1e80c92b1d4723eb65f39c.tar.gz -> stroke.tar.gz
	https://github.com/rime/rime-terra-pinyin/archive/fa30016a9db2cf7d546ce33968c311525f0d90a0.tar.gz -> terra-pinyin.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="*"

DEPEND="app-i18n/librime"
RDEPEND="${DEPEND}"

pkg_setup() {
	# Create the rime group
	enewgroup "rime"
}

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/plum-* "${S}"
}

src_compile() {
	echo "Nothing to compile"
}

src_install() {
	# create directories and files that are needed
	mkdir -p ${ED}/usr/bin/
	mkdir -p ${ED}/usr/share/rime-data
	mkdir -p ${ED}/var/lib/plum
	mkdir -p ${ED}/etc

	# Install the plum source code to /var/lib, the source is required for plum to actually function.
	# There is no standard directory for installing the plum source, instead it is defined by an
	# environment variable. Logically it should be under /var/lib so that's where I put it
	cp "${S}"/* "${ED}"/var/lib/plum -r

	# Copy the script from the source to the binary directory
	cp ${ED}/var/lib/plum/rime-install ${ED}/usr/bin/rime-install

	# Install the data for rime, we cannot use the rime-install package manager since we don't have internet access so we use
	# tarballs provided from artifacts that comprise the minimal package set
	for directory in "${WORKDIR}"/*/; do
		cp -f "${directory}"*.yaml "${directory}"*.txt "${ED}"/usr/share/rime-data &> /dev/null
	done

	# install the plum_dir environment variable
	echo "plum_dir=\"/var/lib/plum\"" >> "${ED}"/etc/environment

	# Manage permissions here
	fowners -R :rime /var/lib/plum/
	fperms -R g+w+s /var/lib/plum/
}

pkg_postinst() {
	elog "To use rime please add yourself to the \"rime\" group to have access"
	elog "to the \"rime-install\" executable. This application is the new"
	elog "database + micro package manager for rime. For more information"
	elog "visit our rime page at:"
	elog "https://www.funtoo.org/Package:IBus/Chinese/rime"
	elog "For more information on how to use the package manager head to the"
	elog "\"Bundled input methods and installing additional ones\" paragraph"
}