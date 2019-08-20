#!/bin/bash

# © Copyright IBM Corporation 2018.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html

if [ -z "$MQSI_VERSION" ]; then
  source /opt/ibm/ace-11/server/bin/mqsiprofile
fi

bar_file=nemService-soapreqto-ace-stub-02-ibm-ace-server-stub.bar
stub_host=$2
stub_port=$3


echo "mqsiapplybaroverride -b /home/aceuser/bars/$bar_file -k nemService -m \"gettheInfo#SOAP Request.webServiceURL\"=\"http://${stub_host}:${stub_port}/sorStub01\""
mqsiapplybaroverride -b /home/aceuser/bars/$bar_file -k nemService -m "gettheInfo#SOAP Request.webServiceURL"="http://${stub_host}:${stub_port}/sorStub01"

mqsireadbar -b /home/aceuser/bars/${bar_file} -r

exit 0
