#!/bin/sh
set -e

RELEASE="desperado:Desperado:12.1:
"
# clean up obsolete stuff
rm -f ./debian/*.install \
    ./debian/*.links \
    ./debian/*.postinst \
    ./debian/*.postrm

#write toplevel Makefile

ALL_CODENAME_SAFE="${ALL_CODENAME_SAFE} $(echo ${RELEASE} | cut -d\: -f1)"

sed -e "s/\@ALL_CODENAME_SAFE\@/${ALL_CODENAME_SAFE}/g" \
    ./debian/templates/Makefile.in \
    > ./Makefile

[ -d ./debian ] || exit 1

TEMPLATE_CHANGELOG="./debian/templates/changelog.in"
sed -e s/\@CODENAME_SAFE\@/$(echo ${RELEASE} | cut -d\: -f1)/g \
    ${TEMPLATE_CHANGELOG} > ./debian/changelog

TEMPLATE_SRC="./debian/templates/control.source.in"
sed     -e s/\@CODENAME_SAFE\@/$(echo ${RELEASE} | cut -d\: -f1)/g \
              ${TEMPLATE_SRC} > ./debian/control

# write debian/control from templates
TEMPLATES_BIN="./debian/templates/control.binary.in"

sed -e s/\@CODENAME_SAFE\@/$(echo ${RELEASE} | cut -d\: -f1)/g \
    -e s/\@CODENAME\@/$(echo ${RELEASE} | cut -d\: -f2)/g \
    -e s/\@VERSION\@/$(echo ${RELEASE} | cut -d\: -f3)/g \
    ${TEMPLATES_BIN} >> ./debian/control

# write debian/*.install from templates
for k in kde kdm ksplash wallpaper wallpaper2 xfce xsplash; do
    if [ -r  ./debian/templates/siduction-art-${k}-CODENAME_SAFE.install.in ]; then
        sed -e s/\@CODENAME_SAFE\@/$(echo ${RELEASE} | cut -d\: -f1)/g \
            ./debian/templates/siduction-art-${k}-CODENAME_SAFE.install.in \
            > ./debian/siduction-art-${k}-$(echo ${RELEASE} | cut -d\: -f1).install
    else
        continue
    fi
done

# link KDE4 style wallpapers to /usr/share/wallpapers/
sed -e s/\@CODENAME_SAFE\@/$(echo ${RELEASE} | cut -d\: -f1)/g \
    ./debian/templates/siduction-art-wallpaper-CODENAME_SAFE.links.in \
    > ./debian/siduction-art-wallpaper-$(echo ${RELEASE} | cut -d\: -f1).links

# link KDE4 style wallpapers to /usr/share/wallpapers/

sed -e s/\@CODENAME_SAFE\@/$(echo ${RELEASE} | cut -d\: -f1)/g \
    ./debian/templates/siduction-art-wallpaper2-CODENAME_SAFE.links.in \
    > ./debian/siduction-art-wallpaper2-$(echo ${RELEASE} | cut -d\: -f1).links

if [ -r  ./debian/siduction-art-wallpaper2-$(echo ${RELEASE} | cut -d\: -f1).install ]; then
    cat ./debian/siduction-art-wallpaper2-$(echo ${RELEASE} | cut -d\: -f1).install >> ./debian/siduction-art-wallpaper-$(echo ${RELEASE} | cut -d\: -f1).install
    cat ./debian/siduction-art-wallpaper2-$(echo ${RELEASE} | cut -d\: -f1).links >> ./debian/siduction-art-wallpaper-$(echo ${RELEASE} | cut -d\: -f1).links
    rm ./debian/siduction-art-wallpaper2-$(echo ${RELEASE} | cut -d\: -f1).install
    rm ./debian/siduction-art-wallpaper2-$(echo ${RELEASE} | cut -d\: -f1).links
fi

cat ./debian/templates/siduction-art-icons.install.in \
    > ./debian/siduction-art-icons.install
