# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils multilib

DESCRIPTION="Intel Concurrent Collections for C++ - Parallelism without the Pain"
HOMEPAGE="https://software.intel.com/en-us/articles/intel-concurrent-collections-for-cc"

if [[ $PV = 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/icnc/icnc.git"
	KEYWORDS=
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE="mpi"

DEPEND="
	>=dev-cpp/tbb-4.2
	sys-libs/glibc
	mpi? ( virtual/mpi )
	"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use mpi BUILD_LIBS_FOR_MPI)
		-DLIB=$(get_libdir)
	)
	cmake-utils_src_configure
}
