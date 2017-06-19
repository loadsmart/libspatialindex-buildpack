VERSION="1.8.5"

SOURCE_URL="http://download.osgeo.org/libspatialindex/spatialindex-src-${VERSION}.tar.gz"
CHECKSUM_URL="http://download.osgeo.org/libspatialindex/spatialindex-src-${VERSION}.tar.gz.md5"


download() {
    local source_url="${1:-$SOURCE_URL}"
    header "Downloading spatialindex-src"
    curl -o spatialindex-src.tar.gz --silent "${source_url}"
}


verify_checksum() {
    info "Verifying checksum"
    curl -o checksum.md5 --silent "${CHECKSUM_URL}"
    openssl md5 spatialindex-src.tar.gz | cut -d' ' -f2
    rm -f checksum.md5
}


install() {
    local prefix="/app/.libs/libspatialindex"

    header "Installing libspatialindex"
    info "Extracting contents"
    tar xzf spatialindex-src.tar.gz
    cd "spatialindex-src-${VERSION}" || exit 1
    info "Running configure"
    ./configure --prefix="${prefix}"
    info "Compiling"
    make
    info "Installing"
    make install

    header "libspatialindex installed on ${prefix}"
}