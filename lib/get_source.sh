download_source() {
    local url="$1"
    _download "${url}" "${TMPDIR}/spatialindex-src.tar.gz"
    echo "${TMPDIR}/spatialindex-src.tar.gz"
}


download_checksum() {
    local url="$1"
    _download "${url}" "${TMPDIR}/checksum.md5"
    echo "${TMPDIR}/checksum.md5"
}


compute_checksum() {
    local filename="$1"
    openssl md5 "${filename}" | cut -d' ' -f2
}


extract_checksum_from_file() {
    local filename="$1"
    cut -f2 -d= "${filename}" | tr -d ' '
}


validate_file() {
    local filename="$1"
    local expected_checksum="$2"

    info "Verifying checksum for downloaded file '${filename}'"

    computed_checksum=$(compute_checksum "$filename")
    if [[ "$computed_checksum" == "$expected_checksum" ]]
    then
        return 0
    else
        return 1
    fi
}


is_installed() {
    local prefix="$1"
    if [ -f "${prefix}/lib/libspatialindex.so" ] || [ -f "${prefix}/lib/libspatialindex.a" ]
    then
        return 0
    else
        return 1
    fi
}


compile() {
    local tarball="$1"
    local prefix="$2"

    header "Installing spatialindex"

    info "Extracting contents to ${TMPDIR}"
    tar -xzf "${tarball}" -C "${TMPDIR}"
    cd "${TMPDIR}/"spatialindex-src-* || exit 1

    info "Configuring"
    ./configure --prefix="${prefix}"

    info "Compiling"
    make

    info "Installing"
    make install

    header "spatialindex compiled on ${prefix}"
}


setup_env() {
    local build_dir="$1"
    local prefix="$2"

    header "Setting paths"

    mkdir -p "${build_dir}/.profile.d"
    cat << EOF > "${build_dir}/.profile.d/spatialindex.sh"
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${prefix}/lib
export SPATIALINDEX_C_LIBRARY=libspatialindex_c.so.4
EOF
}


cleanup() {
    header "Cleaning up downloaded files"

    rm -f "${TMPDIR}/spatialindex-src.tar.gz"
    rm -f "${TMPDIR}/checksum.md5"
    rm -rf "${TMPDIR}/"spatialindex-src-*
}
