#!/usr/bin/env bash
# Initializes a mariadb container with a databasedump and extracts its datadir
# into a seperate container-image.

set -euo pipefail
IFS=$'\n\t'
PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH";
# In case of errors, just write out that we stopped due to an error.
# Cleanup is performed subsequently by the cleanup() trap.
error() {
    echo "Exiting due to error"
    exit $?
}

# Remove all temporary data we can get our hands on.
cleanup() {
  if [[ -f "docker-compose.yml" ]]
    then
    # We should only keep this around until we have generated the datadir.
    echo "Removing temporary dbdata container"
    docker-compose rm --force -v --all
  fi

  if [[ ! -z "${DATADIR_IMAGE_DESTINATION-}" && ! -z $(docker images -q "${DATADIR_IMAGE_DESTINATION}") ]]
    then
    # We should only keep this around until we have done a docker push.
    echo "Removing datadir container"
    docker rmi "${DATADIR_IMAGE_DESTINATION}"
  fi

  if [[ ! -z "${DUMP_IMAGE_SOURCE-}" && ! -z $(docker images -q "${DUMP_IMAGE_SOURCE}") ]]
    then
    # We should only keep this around until docker-compose run has completed
    # and the datadir has been initialized.
    echo "Removing datadump image ${DUMP_IMAGE_SOURCE}"
    docker rmi "${DUMP_IMAGE_SOURCE}"
  fi

  if [[ ! -z "${INTERNAL_VOLUME_PATH-}" && -d "${INTERNAL_VOLUME_PATH}" ]]
    then
    # We should only keep this around until we have done a docker push.
    echo "Removing internal volume directory"
    sudo rm -fr "${INTERNAL_VOLUME_PATH}"
  fi
}

trap error ERR
trap cleanup EXIT

if [ $# -lt 2 ]
  then
    echo "Syntax: ${0} <source user/repo:tag> <destination user/repo:tag> [init-sql-script-path]"
    exit
fi

# Make sure our current directory is the scriptdir.
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPTDIR}"

DATADIR_IMAGE_DESTINATION=$2
DUMP_IMAGE_SOURCE=$1
# Let the user specify a init-script to be run after the db-import.
if [ $# -gt 2 ]
  then
    if [[ ! -e $3 ]]
      then
      echo "Could not find init-script $3"
      exit
    fi
    INITSCRIPT=$3
  else
    INITSCRIPT=''
fi

# Let the user override the base-image, if not overriden use an empty image
# This is only applicable for volumed datadir images.
if [[ -z "${BASE_IMAGE:-}" ]] 
  then
  BASE_IMAGE="tianon/true"
fi

# Let the user request a non-volumned datadir.
# If set to 1 we'll create a complete mariadb image including datadir, placed
# outside a volume. This will let the image start much quicker and save local
# storage as the volume does not have to be created during container startup.
if [[ -z "${NO_VOLUME:-}" ]] 
  then
    NO_VOLUME=0
  else
    # We could support a different base-image here, but until that rather
    # complex situation arrives, we'll keep this tiny bit of extra 
    # complexity out of our quite complex setup here.
    BASE_IMAGE="mariadb:10"
    DATADIR_IMAGE_DESTINATION="${DATADIR_IMAGE_DESTINATION}-novol"
    NO_VOLUME=1
fi

# Support the case where the paths we give to docker has to be different from the local paths
# Path we should give to docker build (ie the real path from the host-server running the docker deamon)
EXTERNAL_VOLUME_BASE="${DATADIR_PREINIT_EXTERNAL_VOLUME-.}"
EXTERNAL_VOLUME_PATH="${EXTERNAL_VOLUME_BASE}/volume"

# Path we should use while inside the inner container (which allows the preinit-script to be run from within a container)
INTERNAL_VOLUME_BASE="${DATADIR_PREINIT_INTERNAL_VOLUME-.}"
INTERNAL_VOLUME_PATH="${INTERNAL_VOLUME_BASE}/volume"

# Create the directory we're going to place files that has to be volume mountable
if [[ -e "${INTERNAL_VOLUME_PATH}" ]]
  then
  echo "Removing previous volume directory ${INTERNAL_VOLUME_PATH}"
  sudo rm -fr "${INTERNAL_VOLUME_PATH}"
fi
mkdir "${INTERNAL_VOLUME_PATH}"

# Get the tag and make sure it is available as a dbdump image.
docker pull "${DUMP_IMAGE_SOURCE}"

# Clean out any existing datadir.
# We need sudo as the datadir will contain files owned by mariadbs "mysql" user.
sudo rm -fr "${INTERNAL_VOLUME_PATH}/datadir"

# Clear out any previously generated composer-file and generate a new.
rm -f docker-compose.yml
/usr/bin/env sed "s%{{DUMP_IMAGE_SOURCE}}%${DUMP_IMAGE_SOURCE}%g" docker-compose.template.yml > docker-compose.yml.tmp
# Volumes are mounted by the docker-deamon potentially running outside the current container
# so make sure to use the external paths.
/usr/bin/env sed -i.bak "s%{{EXTERNAL_VOLUME_PATH}}%${EXTERNAL_VOLUME_PATH}%g" docker-compose.yml.tmp
rm docker-compose.yml.tmp.bak

# Pick up a init-script (ie. sql that should be run after the databasedump has
# been imported) specified on the commandline, and add it to docker-compose.yml.
if [ ! -z $INITSCRIPT ]
  then
    cp $INITSCRIPT "${INTERNAL_VOLUME_PATH}/900-init.sql"
    INITSCRIPTCONFIG="- '${EXTERNAL_VOLUME_PATH}/900-init.sql:/docker-entrypoint-initdb.d/900-init.sql'"
     /usr/bin/env sed -i.bak "s%{{INITSCRIPT}}%${INITSCRIPTCONFIG}%g" docker-compose.yml.tmp
  else
    # No init-script found, remove the placeholder from docker-compose.yml.
    /usr/bin/env sed -i.bak "s/{{INITSCRIPT}}//g" docker-compose.yml.tmp
fi
rm docker-compose.yml.tmp.bak

# All replacements done
mv docker-compose.yml.tmp docker-compose.yml

# Init-script that will make the container exit after importing the dump.
cp "${SCRIPTDIR}/init-only-entrypoint.sh" "${INTERNAL_VOLUME_PATH}/"

# Copy mysql configuration into the dir we're going to use for compose.
cp -r "${SCRIPTDIR}/mysql-config" "${INTERNAL_VOLUME_PATH}/"

# Run up a mariadb container with a sql-dump.
echo "Initializing container with dbdump"
docker-compose rm --force -v --all
docker-compose run preinitdb

# The datadir has now been initialized, clear out all data we don't need.
echo "Removing temporary dbdata container and datadump image"
docker-compose rm --force -v --all
docker rmi "${DUMP_IMAGE_SOURCE}"

# Prepare to run the docker build that will create an image with the datadir.
# If we're not using volumes, use a Dockerfile that places the datadir in an alternate location.
if [[ "$NO_VOLUME" == 1 ]]
  then
    DOCKERFILE_TEMPLATE="Dockerfile-no-volume.template"  
  else
    DOCKERFILE_TEMPLATE="Dockerfile.template"
fi
/usr/bin/env sed "s%{{BASE_IMAGE}}%${BASE_IMAGE}%g" "${DOCKERFILE_TEMPLATE}" > "${INTERNAL_VOLUME_PATH}/Dockerfile"

# Build the pre-init data-container, use same tag as the sql-dump image.
echo "Building ${DATADIR_IMAGE_DESTINATION}"
# Build using same tag as the one from dbdump.
# We need sudo to access datadir.
sudo docker build --tag "${DATADIR_IMAGE_DESTINATION}" -f "${INTERNAL_VOLUME_PATH}/Dockerfile" "${INTERNAL_VOLUME_PATH}"
echo "Pushing ${DATADIR_IMAGE_DESTINATION}"
docker push "${DATADIR_IMAGE_DESTINATION}"
docker rmi "${DATADIR_IMAGE_DESTINATION}"
