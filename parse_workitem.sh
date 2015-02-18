#!/bin/sh
# ==Name
# parse_workitem.sh
#
# ==Description
# This will take a vRA workitem.xml file and create a shell script suitable
# for setting environment variables.  Property names are converted to all
# uppercase and periods are replaced with underscores.  A list of common
# property names and their bash environment variable equivilents follows below
# as a reference guide.
#
# &gt; &lt; &amp; and &apos; are converted to > < & '
#
# Effort has been made to avoid using tools not available on a minimal
# installation of a Linux OS.
#
# Prints output which can be redirected to file. The output can be sourced for
# use in other bash scripts or at startup and available as system wide
# environment variables.
#
# To have environment variables available on startup:
# CentOS
# Redirect output to /etc/profile.d/vcac.sh
#
# ==vRA property names to bash environment variable equivilents
# api.request.id API_REQUEST_ID
# blueprintid BLUEPRINTID
# clonefrom CLONEFROM
# clonefromid CLONEFROMID
# clonespec CLONESPEC
# externalwfstubs.buildingmachine EXTERNALWFSTUBS_BUILDINGMACHINE
# externalwfstubs.buildingmachine.vcachost EXTERNALWFSTUBS_BUILDINGMACHINE_VCACHOST
# externalwfstubs.buildingmachine.vcacvm EXTERNALWFSTUBS_BUILDINGMACHINE_VCACVM
# externalwfstubs.buildingmachine.virtualmachineentity EXTERNALWFSTUBS_BUILDINGMACHINE_VIRTUALMACHINEENTITY
# externalwfstubs.machinedisposing EXTERNALWFSTUBS_MACHINEDISPOSING
# externalwfstubs.machineprovisioned EXTERNALWFSTUBS_MACHINEPROVISIONED
# infrastructure.admin.machineobjectou INFRASTRUCTURE_ADMIN_MACHINEOBJECTOU
# infrastructure.resourcepool.name INFRASTRUCTURE_RESOURCEPOOL_NAME
# legacy.workflow.impersonatinguser LEGACY_WORKFLOW_IMPERSONATINGUSER
# legacy.workflow.user LEGACY_WORKFLOW_USER
# machine.ssh MACHINE_SSH
# notes NOTES
# provisioninggroupid PROVISIONINGGROUPID
# request_reason REQUEST_REASON
# virtualmachine.admin.addownertoadmins VIRTUALMACHINE_ADMIN_ADDOWNERTOADMINS
# virtualmachine.admin.administratoremail VIRTUALMACHINE_ADMIN_ADMINISTRATOREMAIL
# virtualmachine.admin.agentid VIRTUALMACHINE_ADMIN_AGENTID
# virtualmachine.admin.clustername VIRTUALMACHINE_ADMIN_CLUSTERNAME
# virtualmachine.admin.description VIRTUALMACHINE_ADMIN_DESCRIPTION
# virtualmachine.admin.dnsname VIRTUALMACHINE_ADMIN_DNSNAME
# virtualmachine.admin.hostidentity VIRTUALMACHINE_ADMIN_HOSTIDENTITY
# virtualmachine.admin.hostname VIRTUALMACHINE_ADMIN_HOSTNAME
# virtualmachine.admin.id VIRTUALMACHINE_ADMIN_ID
# virtualmachine.admin.name VIRTUALMACHINE_ADMIN_NAME
# virtualmachine.admin.owner VIRTUALMACHINE_ADMIN_OWNER
# virtualmachine.admin.proxyagentid VIRTUALMACHINE_ADMIN_PROXYAGENTID
# virtualmachine.admin.totaldiskusage VIRTUALMACHINE_ADMIN_TOTALDISKUSAGE
# virtualmachine.admin.useguestagent VIRTUALMACHINE_ADMIN_USEGUESTAGENT
# virtualmachine.admin.uuid VIRTUALMACHINE_ADMIN_UUID
# virtualmachine.cpu.count VIRTUALMACHINE_CPU_COUNT
# virtualmachine.customize.waitcomplete VIRTUALMACHINE_CUSTOMIZE_WAITCOMPLETE
# virtualmachine.disk0.deviceid VIRTUALMACHINE_DISK0_DEVICEID
# virtualmachine.disk0.externalid VIRTUALMACHINE_DISK0_EXTERNALID
# virtualmachine.disk0.isclone VIRTUALMACHINE_DISK0_ISCLONE
# virtualmachine.disk0.isfixed VIRTUALMACHINE_DISK0_ISFIXED
# virtualmachine.disk0.name VIRTUALMACHINE_DISK0_NAME
# virtualmachine.disk0.size VIRTUALMACHINE_DISK0_SIZE
# virtualmachine.disk0.storage VIRTUALMACHINE_DISK0_STORAGE
# virtualmachine.leasedays VIRTUALMACHINE_LEASEDAYS
# virtualmachine.managementendpoint.endpoint0 VIRTUALMACHINE_MANAGEMENTENDPOINT_ENDPOINT0
# virtualmachine.managementendpoint.identity VIRTUALMACHINE_MANAGEMENTENDPOINT_IDENTITY
# virtualmachine.managementendpoint.name VIRTUALMACHINE_MANAGEMENTENDPOINT_NAME
# virtualmachine.memory.size VIRTUALMACHINE_MEMORY_SIZE
# virtualmachine.network0.address VIRTUALMACHINE_NETWORK0_ADDRESS
# virtualmachine.network0.dnssearchsuffixes VIRTUALMACHINE_NETWORK0_DNSSEARCHSUFFIXES
# virtualmachine.network0.dnssuffix VIRTUALMACHINE_NETWORK0_DNSSUFFIX
# virtualmachine.network0.gateway VIRTUALMACHINE_NETWORK0_GATEWAY
# virtualmachine.network0.macaddress VIRTUALMACHINE_NETWORK0_MACADDRESS
# virtualmachine.network0.name VIRTUALMACHINE_NETWORK0_NAME
# virtualmachine.network0.primarydns VIRTUALMACHINE_NETWORK0_PRIMARYDNS
# virtualmachine.network0.primarywins VIRTUALMACHINE_NETWORK0_PRIMARYWINS
# virtualmachine.network0.secondarydns VIRTUALMACHINE_NETWORK0_SECONDARYDNS
# virtualmachine.network0.secondarywins VIRTUALMACHINE_NETWORK0_SECONDARYWINS
# virtualmachine.network0.subnetmask VIRTUALMACHINE_NETWORK0_SUBNETMASK
# virtualmachine.software0.name VIRTUALMACHINE_SOFTWARE0_NAME
# virtualmachine.software0.scriptpath VIRTUALMACHINE_SOFTWARE0_SCRIPTPATH
# virtualmachine.storage.name VIRTUALMACHINE_STORAGE_NAME
# vrm.proxyagent.uri VRM_PROXYAGENT_URI
# vrm.software.command VRM_SOFTWARE_COMMAND
#
# ==Parameters
# None.
#
# ==Arguments
# None.
#
# ==Variables
# [*FILENAME*]
# Name of the workitem.xml file as of vRA 6.2
#
# [*NAME*]
# Name of the environment varible to set.
#
# [*VALUE*]
# Value of the environment variable to set.
#
# ==Author
# mike@marseglia.org

# look for undeclared variables
set -u

# full path to the workitem.xml file
FILENAME='/usr/share/gugent/site/workitem.xml'

# exit if the workitem.xml file cannot be found
if [[ ! -f $FILENAME ]]; then
  echo "$0: workitem.xml file not found at $FILENAME"
  exit 1
fi

# get the contents of the file
cat $FILENAME|grep property|while read line; do

  # extract the variable name
  NAME=`expr "$line" : '^.*name="\(.*\)" value.*$'`

  # set variable name to all uppercase
  NAME=`echo $NAME|tr '[a-z]' '[A-Z]'`

  # bash variable names cannot contain periods so I replace them with _
  NAME=${NAME//./_}

  # extract value for the current variable
  VALUE=`expr "$line" : '^.*value=\(".*"\).*$'`

  # replace &gt; &lt; &amp; and &apos; with > < & '
  VALUE=${VALUE//&gt;/>}
  VALUE=${VALUE//&lt;/<}
  VALUE=${VALUE//&amp;/&}
  VALUE=${VALUE//&apos;/\'}

  # echo result to stdout
  echo export $NAME=$VALUE
done

exit 0
