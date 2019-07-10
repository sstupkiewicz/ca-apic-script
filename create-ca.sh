#!/bin/bash

# cleanup
rm *.pem *.csr index* serial* > /dev/null 2>&1

DOMAIN="ibm.example.org"
SUBJECT_BASE="/C=UK/ST=Hursley/L=IBM/emailAddress=me@me.com"
ENDPOINTS="cloud manager consumer platform portal gw"
SERVER_TPL=openssl-server.cnf

touch index.txt
echo '01' > serial.txt

openssl req -x509 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out cacert.pem -outform PEM -subj "$SUBJECT_BASE/CN=$DOMAIN"

for endpoint in ${ENDPOINTS}; do
	cp -f ${SERVER_TPL} ${endpoint}.cnf
	echo "DNS.1 = ${endpoint}.${DOMAIN}" >> ${endpoint}.cnf
	openssl req -config ${endpoint}.cnf -newkey rsa:2048 -sha256 -nodes -out ${endpoint}.csr -outform PEM -subj "${SUBJECT_BASE}/CN=${endpoint}.${DOMAIN}"
	openssl ca -batch -config openssl-ca.cnf -policy signing_policy -extensions signing_req -out ${endpoint}.pem -infiles ${endpoint}.csr
	cp -f serverkey.pem ${endpoint}.key.pem
done
