# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI=2
PYTHON_DEPEND="2:2.4"

inherit distutils eutils

DESCRIPTION="SALOME : The Open Source Integration Platform for Numerical Simulation. PYCALCULATOR Component"
HOMEPAGE="http://www.salome-platform.org"
SRC_URI="http://www.stasyan.com/devel/distfiles/src${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="debug doc"

RDEPEND="debug?   ( dev-util/cppunit )
		 >=sci-misc/salome-kernel-${PV}
		 >=sci-misc/salome-med-${PV}
		 >=sci-misc/salome-component-${PV}
		 >=dev-python/omniorbpy-3.4
		 >=net-misc/omniORB-4.1.4
		 >=sci-libs/med-2.3.5"

DEPEND="${RDEPEND}
		>=app-doc/doxygen-1.5.6
		media-gfx/graphviz
		>=dev-python/docutils-0.4"

MODULE_NAME="PYCALCULATOR"
MY_S="${WORKDIR}/src${PV}/${MODULE_NAME}_SRC_${PV}"
INSTALL_DIR="/opt/salome-${PV}/${MODULE_NAME}"
PYCALCULATOR_ROOT_DIR="/opt/salome-${PV}/${MODULE_NAME}"
export OPENPBS="/usr"

pkg_setup() {
	PYVER=$(python_get_version)
	[[ ${PYVER} > 2.4 ]] && \
		ewarn "Python 2.4 is highly recommended for Salome..."
}

src_prepare() {
	cd "${MY_S}"

	rm -r -f autom4te.cache
	./build_configure
}

src_configure() {
	cd "${MY_S}"

	econf --prefix=${INSTALL_DIR} \
	      --datadir=${INSTALL_DIR}/share/salome \
	      --docdir=${INSTALL_DIR}/doc/salome \
	      --infodir=${INSTALL_DIR}/share/info \
	      --libdir=${INSTALL_DIR}/$(get_libdir)/salome \
	      --with-python-site=${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages/salome \
	      --with-python-site-exec=${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages/salome \
	      $(use_enable debug ) \
	      $(use_enable !debug production ) \
	|| die "econf failed"
}

src_compile() {
	cd "${MY_S}"

	emake || die "emake failed"
}

src_install() {
	cd "${MY_S}"

	emake DESTDIR="${D}" install || die "emake install failed"

	use amd64 && dosym ${INSTALL_DIR}/lib64 ${INSTALL_DIR}/lib

	echo "${MODULE_NAME}_ROOT_DIR=${INSTALL_DIR}" > ./90${P}
	echo "LDPATH=${INSTALL_DIR}/$(get_libdir)/salome" >> ./90${P}a
	echo "PATH=${INSTALL_DIR}/bin/salome" >> ./90${P}
	echo "PYTHONPATH=${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages/salome" >> ./90${P}
	doenvd 90${P}
	rm adm_local/Makefile
	insinto "${INSTALL_DIR}"
	doins -r adm_local

	use doc && dodoc INSTALL
}

pkg_postinst() {
	elog "Run \`env-update && source /etc/profile\`"
	elog "now to set up the correct paths."
	elog ""
}
