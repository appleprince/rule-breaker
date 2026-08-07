#!/bin/bash

set -euxo pipefail

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--input)
      INPUT="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--output)
      OUTPUT="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

mkdir -p build

echo Generate CA key:
(cd build && openssl genrsa -passout pass:1111 -des3 -out ca.key 4096)

echo Generate CA certificate:
(cd build && openssl req -passin pass:1111 -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=TW/ST=Taiwan/L=Taipei/O=Suisei/CN=SuiseiCA")

echo Generate server key:
(cd build && openssl genrsa -passout pass:1111 -des3 -out server.key 4096)

echo Generate server signing request:
(cd build && openssl req -passin pass:1111 -new -key server.key -out server.csr -subj "/C=TW/ST=Taiwan/L=Taipei/O=Suisei/CN=localhost")

echo Self-sign server certificate:
(cd build && openssl x509 -req -passin pass:1111 -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1"))

echo Remove passphrase from server key:
(cd build && openssl rsa -passin pass:1111 -in server.key -out server.key)

echo Generate client key:
(cd build && openssl genrsa -passout pass:1111 -des3 -out client.key 4096)

echo Generate client signing request:
(cd build && openssl req -passin pass:1111 -new -key client.key -out client.csr -subj "/C=TW/ST=Taiwan/L=Taipei/O=Suisei/CN=localhost")

echo Self-sign client certificate:
(cd build && openssl x509 -passin pass:1111 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1"))

echo Remove passphrase from client key:
(cd build && openssl rsa -passin pass:1111 -in client.key -out client.key)

(cd build && 7z a -y -p"$PASSWORD" "../$OUTPUT" *)

rm -rf build

