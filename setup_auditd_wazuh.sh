#!/bin/bash
# setup_auditd_wazuh.sh - Script de Estandarización de Auditoría
# Autor: Carlos Valenzuela - Ciberseguridad

# Verificar root
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Por favor, ejecutar como root (sudo)."
  exit 1
fi

echo ">>> [1/5] Instalando paquetes de auditoría..."
# El -q evita salida excesiva
apt-get update -q 
apt-get install -y auditd audispd-plugins

echo ">>> [2/5] Asegurando limpieza de configuraciones previas..."
# Borramos todo para asegurar que no haya conflictos
rm -f /etc/audit/rules.d/*
rm -f /etc/audit/audit.rules

echo ">>> [3/5] Aplicando reglas estándar (Golden Master)..."
cat > /etc/audit/rules.d/00-wazuh-standard.rules << 'RULES'
## Reglas Base Ciberseguridad - Estandarizado
-D
-b 8192
-f 1

## Identidad y Usuarios (PCI DSS / CIS)
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

## Red y Sistema
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network/ -p wa -k system-locale

## Privilegios (Sudoers)
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

## Integridad de Tiempo
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
RULES

echo ">>> [4/5] Compilando reglas y recargando servicio..."
# Generamos el binario de reglas
augenrules --load
# Limpiamos memoria por si acaso
auditctl -D >/dev/null 2>&1
# Cargamos configuración
auditctl -R /etc/audit/audit.rules
# Habilitamos y reiniciamos el servicio
systemctl enable auditd
systemctl restart auditd

echo ">>> [5/5] VALIDACIÓN FINAL - Reglas Activas:"
echo "----------------------------------------"
auditctl -l
echo "----------------------------------------"
echo ">>> Proceso finalizado exitosamente."
