FROM golang:1.17.8 AS builder
WORKDIR /
COPY . .
RUN make

FROM ubuntu:22.04

RUN apt-get update -y &&\
    apt-get install net-tools -y &&\
    apt-get install ca-certificates -y &&\
    apt-get install iptables -y


WORKDIR /

COPY --from=builder /iptables-server .

ENTRYPOINT ["/iptables-server"]


