# ----------------------------------------------------------------------------
# Spack package specification for ROMS-ETHZ
#
#  Usage:
#     spack install roms-ethz
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class RomsEthz(MakefilePackage):
    """
    ETH Zurich (UP) version of ROMS (Regional Ocean Modeling System)
    """

    # URL and homepage
    homepage = "https://www.myroms.org"  # Rutgers documentation of ROMS
    git      = "https://spack:2Tp6jMxSLXS7sLseQ9Vr@gitlab.ethz.ch/muennicm/roms_src_ethz"


    # GitHub accounts to notify when the package is updated.
    maintainers = ['mattmunnich']

    # Versions 
    version("master", branch="master")
    version("vSpack1", commit="dde547bac55445f08b10a6c0e0325da2a5ee9238")

    # Variants
    variant("tools", default=False, description="Also install netCDF partit and ncjoin tools")
    variant("oasis", default=True, description="Compile with OASIS coupling interface, i.e., for ROMSOC")
    variant("nczarr", default=False, description="With NCZarr support")
    variant("config", 
            default="PACTC", 
            description="ROMS configuration, e.g. a cppdefs_<config>.h. Default <config> is e.g., 'PACTC'(default).",
            values=("PACTC", "PACTC60", "HUMPAC", "N_HUMPAC", "SO", "AMACAN", "UCYN", "BENGT", "ONEDIM", "MOONS"), 
            multi=False
            )

    # Dependencies (default spack type is only build, link)
    depends_on('mpi +fortran', type=('build', 'link', 'run'))
    depends_on('netcdf-fortran', type=('build', 'link', 'run'))
    depends_on("netcdf-c@:8", when="+nczarr", type=('build', 'link', 'run')) # for netCDF Zarr storage
    depends_on("oasis", when="+oasis", type=('build', 'link', 'run'))


    @property
    def build_targets(self):
        targets = []
        if "+oasis" in self.spec:
            targets.append("roms_cpl")
        else:
            targets.append("roms")
        if "+tools" in self.spec:
            targets.append("nctools")
        return targets


    def edit(self, spec, prefix):
        env["PREFIX"] = prefix
        env["FC"] =  spec["mpi"].mpifc
        if "config" in self.spec:
            env["config"] = self.spec['config'] 
        else:
            env["config"] = 'PACTC'
        env["Q"] = '' # verbose make

