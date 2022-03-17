#!/bin/bash

# cleanup
rm *.pem *.csr index* serial* > /dev/null 2>&1

DOMAIN="think.ibm"
SUBJECT_BASE="/C=US/ST=Columbus/L=IBM/emailAddress=student@think.ibm"
ENDPOINTS="admin manager consumer api portal rgw datapower"
SERVER_TPL=openssl-server.cnf

touch index.txt
echo '01' > serial.txt

echo -n "Generating CA certificate and key"
openssl req -x509 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out cacert.pem -outform PEM -subj "$SUBJECT_BASE/CN=$DOMAIN" > /dev/null 2>&1
echo ". Complete!"

for endpoint in ${ENDPOINTS}; do
	echo -n "Generating certificate and key for $endpoint.$DOMAIN"
	cp -f ${SERVER_TPL} ${endpoint}.cnf
	echo -n " ."
	echo "DNS.1 = ${endpoint}.${DOMAIN}" >> ${endpoint}.cnf
	openssl req -config ${endpoint}.cnf -newkey rsa:2048 -sha256 -nodes -out ${endpoint}.csr -outform PEM -subj "${SUBJECT_BASE}/CN=${endpoint}.${DOMAIN}" > /dev/null 2>&1
	echo -n "."
	openssl ca -batch -config openssl-ca.cnf -policy signing_policy -extensions signing_req -out ${endpoint}.pem -infiles ${endpoint}.csr > /dev/null 2>&1
	echo -n "."
	mv -f serverkey.pem ${endpoint}.key.pem
	echo ". Complete!"
done
