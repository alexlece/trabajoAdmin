#!/bin/bash
#Rechazar por defecto
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP

iptables -P OUTPUT ACCEPT

# Bloquear pings del host
iptables -A INPUT -i enp0s10 -p icmp --icmp-type echo-request -j REJECT

#Acepto el tráfico de entrada redes internas
iptables -A OUTPUT -o enp0s3 -p all -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i enp0s3 -p all -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o enp0s10 -p all -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i enp0s10 -p all -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -o enp0s10 -i enp0s8 -p all -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s8 -p all -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -o enp0s3 -i enp0s8 -p all -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p all -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -o enp0s10 -i enp0s9 -p all -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s9 -p all -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -o enp0s3 -i enp0s9 -p all -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s9 -p all -m state --state ESTABLISHED -j ACCEPT

#aceptar trafico entre redes internas
iptables -A INPUT -j ACCEPT -p all -i enp0s8
iptables -A INPUT -j ACCEPT -p all -i enp0s9
iptables -A FORWARD -j ACCEPT -p all -i enp0s8 -o enp0s9
iptables -A FORWARD -o enp0s8 -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -o enp0s9 -i enp0s8 -p all -j ACCEPT

#ssh
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to 192.168.59.2:22
iptables -A FORWARD -d 192.168.59.2 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s 192.168.59.2 -p tcp --sport 22 -j ACCEPT

#rutas para los servicios http y ssh desde red solo anfitrión
#http
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 192.168.56.2:80
iptables -A FORWARD -d 192.168.56.2 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 192.168.56.2 -p tcp --sport 80 -j ACCEPT

#permitir el tráfico hacia extranet internet   
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.10
iptables -t nat -A POSTROUTING -s 192.168.56.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.57.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.59.0/24 -o enp0s3 -j MASQUERADE

#permitir loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
