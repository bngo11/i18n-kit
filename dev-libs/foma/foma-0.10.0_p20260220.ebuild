# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Multi-purpose finite-state toolkit"
HOMEPAGE="https://fomafst.github.io/ https://github.com/mhulden/foma"
SRC_URI="https://github.com/mhulden/foma/archive/13b0e97ee3b0aaa6e7cc7ba8110e0ddbc456c46a.tar.gz -> foma-0.10.0_p20260220.tar.gz"

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