#!/bin/sh

. env.sh

# update sources
update_sources_and_spec ()
{
    pushd $REPO_DIR/$PACKAGE
    git fetch --all
    git checkout $BRANCH
    export D_COMMIT=$(git show --pretty=%H -s $BRANCH)
    export D_SHORTCOMMIT=$(c=$D_COMMIT; echo ${c:0:7})
    export VERSION=$(sed -e 's/-.*//' VERSION)
    popd

    pushd $REPO_DIR/$PACKAGE-storage-setup
    git fetch origin
    export DSS_COMMIT=$(git show --pretty=%H -s origin/master)
    export DSS_SHORTCOMMIT=$(c=$DSS_COMMIT; echo ${c:0:7})
    popd

    pushd $REPO_DIR/$PACKAGE-selinux
    git fetch origin
    export DS_COMMIT=$(git show --pretty=%H -s origin/$DS_BRANCH)
    export DS_SHORTCOMMIT=$(c=$DS_COMMIT; echo ${c:0:7})
    popd

    pushd $REPO_DIR/$PACKAGE-utils
    git fetch origin
    export UTILS_COMMIT=$(git show --pretty=%H -s origin/master)
    export UTILS_SHORTCOMMIT=$(c=$UTILS_COMMIT; echo ${c:0:7})
    popd

    pushd $REPO_DIR/$PACKAGE-novolume-plugin
    git fetch origin
    export NOVOLUME_COMMIT=$(git show --pretty=%H -s origin/master)
    export NOVOLUME_SHORTCOMMIT=$(c=$UTILS_COMMIT; echo ${c:0:7})
    popd

    pushd $PKG_DIR/$PACKAGE
    git checkout $DIST_GIT_TAG
    sed -i "s/\%global commit0.*/\%global commit0 $D_COMMIT/" $PACKAGE.spec
    sed -i "s/\%global commit2.*/\%global commit2 $DS_COMMIT/" $PACKAGE.spec
    sed -i "s/\%global commit1.*/\%global commit1  $DSS_COMMIT/" $PACKAGE.spec
    sed -i "s/\%global commit3.*/\%global commit3  $UTILS_COMMIT/" $PACKAGE.spec
    sed -i "s/\%global commit4.*/\%global commit4  $NOVOLUME_COMMIT/" $PACKAGE.spec

    echo "- built docker @$BRANCH commit#$D_SHORTCOMMIT" > /tmp/$PACKAGE.changelog
    echo "- built docker-selinux commit#$DS_SHORTCOMMIT" >> /tmp/$PACKAGE.changelog
    echo "- built d-s-s commit#$DSS_SHORTCOMMIT" >> /tmp/$PACKAGE.changelog
    echo "- built docker-utils commit#$UTILS_SHORTCOMMIT" >> /tmp/$PACKAGE.changelog
    echo "- built docker-novolume-plugin commit#$NOVOLUME_SHORTCOMMIT" >> /tmp/$PACKAGE.changelog
    popd
}


#-------
# CentOS
#-------

# remove stale docker-master.spec
#rm docker-master.spec

# copy latest docker.spec to docker-master.spec
#cp docker.spec docker-master.spec

# change package name for docker-master
#sed -i "s/Name: \%{repo}/Name: \%{repo}-master/" docker-master.spec

# docker-master Provides: docker
#sed -i "/Name: %{repo}-master/a Provides: %{repo} = %{version}-%{release}" \
#    docker-master.spec

# modify build tags for el7
#sed -i 's/selinux\"/selinux btrfs_noversion\"/' docker-master.spec

# build for el7
#rpmbuild --define 'dist .el7' -ba docker-master.spec --nocheck

# ckoji is a symlink to koji which uses my CentOS koji config
#~/bin/ckoji build virt7-el7 SRPMS/docker-master-*.el7.src.rpm
#~/bin/ckoji tag-pkg virt7-docker-master-testing $(ls SRPMS | sed -e "s/\.src.*//")
