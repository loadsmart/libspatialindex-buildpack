VERSION="1.8.5"

SOURCE_URL="http://download.osgeo.org/libspatialindex/spatialindex-src-${VERSION}.tar.gz"
CHECKSUM_URL="http://download.osgeo.org/libspatialindex/spatialindex-src-${VERSION}.tar.gz.md5"


download() {
    local source_url="$1"
    local cache_dir="$2"

    if [ -z "$source_url" ]
    then
        source_url="${SOURCE_URL}"
    fi

    header "Downloading spatialindex-src from '${source_url}'"
    curl -o "spatialindex-src.tar.gz" --silent --show-error "${source_url}"
}


_get_checksum_from_file() {
    local filename="$1"

    cut -f2 -d= "$filename" | tr -d ' '
}


verify_checksum() {
    local cache_dir="$1"
    local computed_checksum ref_checksum

    info "Verifying checksum"
    curl -o "checksum.md5" --silent --show-error "${CHECKSUM_URL}"
    computed_checksum=$(openssl md5 "spatialindex-src.tar.gz" | cut -d' ' -f2)
    ref_checksum=$(_get_checksum_from_file checksum.md5)
    if [[ "$computed_checksum" != "$ref_checksum" ]]
    then
        header "Checksum failed - expected '${ref_checksum}' but found '${computed_checksum}'"
        exit 1
    fi
    rm -f checksum.md5
}


compile() {
    local build_dir="$1"
    local cache_dir="$2"
    local prefix="${cache_dir}"

    header "Installing libspatialindex"

    if [ -f "${prefix}/lib/libspatialindex.so" ]
    then
        info "libspatialindex already compiled, skipping"
        return
    fi

    info "Extracting contents"
    tar xzf "spatialindex-src.tar.gz"
    cd "spatialindex-src-${VERSION}" || exit 1
    info "Running configure"
    ./configure --prefix="${prefix}"
    info "Compiling"
    make
    info "Installing"
    make install

    header "libspatialindex compiled on ${prefix}"
}


install() {
    local build_dir="$1"
    local cache_dir="$2"

    header "Copying libspatialindex to .libs"

    mkdir "${build_dir}/.libs"
    cp -a "${cache_dir}" "${build_dir}/.libs"
}
