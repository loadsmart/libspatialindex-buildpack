VERSION="1.8.5"

SOURCE_URL="http://download.osgeo.org/libspatialindex/spatialindex-src-${VERSION}.tar.gz"
CHECKSUM_URL="http://download.osgeo.org/libspatialindex/spatialindex-src-${VERSION}.tar.gz.md5"


download() {
    local source_url="${1:-$SOURCE_URL}"
    header "Downloading spatialindex-src"
    curl -o spatialindex-src.tar.gz --silent "${source_url}"
}


_get_checksum_from_file() {
    local filename="$1"

    cut -f2 -d= "$filename" | tr -d ' '
}


verify_checksum() {
    local computed_checksum ref_checksum

    info "Verifying checksum"
    curl -o checksum.md5 --silent "${CHECKSUM_URL}"
    computed_checksum=$(openssl md5 spatialindex-src.tar.gz | cut -d' ' -f2)
    ref_checksum=$(_get_checksum_from_file checksum.md5)
    [[ "$computed_checksum" == "$ref_checksum" ]] || header "Checksum failed - expected '${ref_checksum}' but found '${computed_checksum}'" && exit 1
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
