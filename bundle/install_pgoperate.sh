#!/usr/bin/env bash

# Copyright 2020 Trivadis AG <info@trivadis.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author:  Aychin Gasimov (AYG)
# Desc: Script to install pgBasEnv from scratch or upgrade existing version.
#       Check README.md for details.
#
# Change log:
#   06.05.2020: Aychin: Initial version created
#
#

# Defaults
TVDBASE_DEF=$HOME/tvdtoolbox



#########################################################################################

unset TVDBASE


if [[ "$1" =~ -h|--help ]]; then
  echo "
  pgOperate installation script.
  "
  exit 0
fi


TARFILE=$(ls -1 pgoperate-*.tar 2>/dev/null | sort -n -t"-" -k2 | tail -1)
if [[ -z $TARFILE ]]; then
	echo "ERROR: Tar file pgoperate-<VERSION>.tar do not found in current directory!"
	exit 1
else
  echo
  echo "Installing from $TARFILE"
  echo
fi

[[ ! -f $HOME/.PGBASENV_HOME ]] && echo -e "\nERROR: PgBaseEnv is required for PgOperate. Please install it first.\n" && exit 1

TVDBASE=$(grep TVDBASE= $HOME/.PGBASENV_HOME | cut -d"=" -f2 | xargs)
[[ -z $TVDBASE ]] && echo -e "\nERROR: PgBaseEnv is required for PgOperate. Please install it first.\n" && exit 1

source $HOME/.PGBASENV_HOME

echo "TVDBASE already defined as $TVDBASE"

TVDBASE=$(eval "echo $TVDBASE")

echo "TVDBASE: $TVDBASE"


PGOPERATE_BASE=$TVDBASE/pgoperate

echo -e "\n>>> INSTALLATION STEP: Creating directory if not exists $TVDBASE/pgoperate.\n"
mkdir -p $TVDBASE/pgoperate
[[ $? -gt 0 ]] && echo "ERROR: Cannot continue! Check the path specified." && exit 1 || echo "SUCCESS"

echo -e "\n>>> INSTALLATION STEP: Extracting files into $TVDBASE/pgoperate.\n"
tar -xvf $TARFILE -C $TVDBASE
[[ $? -gt 0 ]] && echo "ERROR: Cannot continue! Check the output and fix issue." && exit 1 || echo "SUCCESS"

echo -e "\n>>> INSTALLATION STEP: Add aliases to \$PGBASENV_BASE/etc/pgbasenv_standard.conf.\n"
sed -i "/# pgOperate/d" $PGBASENV_BASE/etc/pgbasenv_standard.conf
sed -i "/alias pgoperate=.*/d" $PGBASENV_BASE/etc/pgbasenv_standard.conf
sed -i "/alias cdbase=.*/d" $PGBASENV_BASE/etc/pgbasenv_standard.conf
sed -i "/alias cdpo=.*/d" $PGBASENV_BASE/etc/pgbasenv_standard.conf
sed -i "/alias cdpo.etc=.*/d" $PGBASENV_BASE/etc/pgbasenv_standard.conf

echo "
# pgOperate
alias pgoperate=\"\$PGOPERATE_BASE/bin/pgoperate\"
alias cdbase='eval \"cd \$(test -f \$PGOPERATE_BASE/etc/parameters_\${PGBASENV_ALIAS}.conf && grep \"^PGSQL_BASE\" \$PGOPERATE_BASE/etc/parameters_\${PGBASENV_ALIAS}.conf | cut -d\"=\" -f2 || echo \".\")\"'
alias cdpo='cd \$PGOPERATE_BASE'
alias cdpo.etc='cd \$PGOPERATE_BASE/etc'
" >> $PGBASENV_BASE/etc/pgbasenv_standard.conf
alias 

echo -e "\n>>> INSTALLATION STEP: Update \$PGOPERATE_BASE/bin/root.sh with current username.\n"
sed -i "s/^USER=.*/USER=$(id -un)/g" $PGOPERATE_BASE/bin/root.sh
sed -i "s/^GROUP=.*/GROUP=$(id -gn)/g" $PGOPERATE_BASE/bin/root.sh
sed -i "s/^PGOPERATE_BASE=.*/PGOPERATE_BASE=${PGOPERATE_BASE//\//\\/}/g" $PGOPERATE_BASE/bin/root.sh

echo -e "\nInstallation successfully completed."

echo -e "\nNow execute $TVDBASE/pgoperate/bin/root.sh as root user.\n"


exit 0
