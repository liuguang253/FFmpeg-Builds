#!/bin/bash

VORBIS_REPO="https://github.com/xiph/vorbis.git"
VORBIS_COMMIT="4a767c9ead99d36f7dee4d45cabb6636dd9e8a75"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/vorbis.sh"
    to_df "RUN bash -c 'source /root/vorbis.sh && ffbuild_dockerbuild && rm /root/vorbis.sh'"
}

ffbuild_dockerbuild() {
    git clone "$VORBIS_REPO" vorbis || return -1
    cd vorbis
    git checkout "$VORBIS_COMMIT" || return -1

    ./autogen.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-oggtest
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf vorbis
}

ffbuild_configure() {
    echo --enable-libvorbis
}

ffbuild_unconfigure() {
    echo --disable-libvorbis
}