# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Multi-purpose finite-state toolkit"
HOMEPAGE="https://fomafst.github.io/ https://github.com/mhulden/foma"
SRC_URI="https://github.com/mhulden/foma/archive/91f91866af843aec487313d028dbd1f76b5fb1a5.tar.gz -> foma-0.10.0_p20250909.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

BDEPEND="sys-devel/bison
	sys-devel/flex"
DEPEND="sys-libs/readline:=
	sys-libs/zlib"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/foma-* "${S}"
	S="${S}"/foma/
	elog "${S}"
}

src_install() {
	cmake_src_install
	find "${D}" -name '*.a' -delete || die
}