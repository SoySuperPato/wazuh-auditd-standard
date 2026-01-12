# Wazuh Auditd Standardizer | Estandarización de Auditoría Linux

Script de Bash para desplegar automáticamente una configuración de auditoría (`auditd`) limpia, optimizada y alineada con estándares de seguridad (PCI-DSS / CIS) para su ingesta en Wazuh SOC.

## 📋 Tabla de Contenidos

* [Descripción](https://www.google.com/search?q=%23-descripci%C3%B3n)
* [Requisitos](https://www.google.com/search?q=%23-requisitos)
* [Instalación y Uso](https://www.google.com/search?q=%23-instalaci%C3%B3n-y-uso)
* [¿Qué hace el script?](https://www.google.com/search?q=%23-qu%C3%A9-hace-el-script)
* [Cobertura de Reglas (Golden Master)](https://www.google.com/search?q=%23-cobertura-de-reglas-golden-master)
* [Validación](https://www.google.com/search?q=%23-validaci%C3%B3n)
* [Contribuciones y Autor](https://www.google.com/search?q=%23-contribuciones-y-autor)

## 📌 Descripción

Este repositorio contiene la herramienta estándar para preparar servidores **Ubuntu** y **Debian** antes de ser integrados al monitoreo del SOC. El objetivo principal es eliminar el "ruido" generado por configuraciones por defecto y asegurar que solo se auditen eventos críticos de seguridad.

**Problema que resuelve:**
Las configuraciones manuales o por defecto suelen auditar recursivamente directorios como `/etc`, generando miles de eventos basura (falsos positivos) que saturan el SIEM/Wazuh.

**Solución:**
Este script aplica una **"Línea Base" (Baseline)** quirúrgica que monitorea integridad de archivos, cambios de red y ejecución de privilegios sin impactar el rendimiento.

## 🛠️ Requisitos

* **Sistema Operativo:** Ubuntu (20.04/22.04/24.04) o Debian (10/11/12).
* **Privilegios:** Se requiere acceso `root` o `sudo` para instalar paquetes y modificar parámetros del kernel.
* **Wazuh Agent:** (Opcional) El script prepara el sistema operativo; el agente de Wazuh leerá los logs generados en `/var/log/audit/audit.log`.

## ⬇️ Instalación y Uso

Este script está diseñado para ser "copiar y ejecutar". No requiere dependencias externas complejas.

### 1. Descarga el script

Clona el repositorio o copia el archivo `setup_auditd_wazuh.sh` al servidor destino:

```bash
git clone https://github.com/TuUsuario/wazuh-auditd-standard.git
cd wazuh-auditd-standard

```

### 2. Ejecución

Da permisos de ejecución y corre el script como superusuario:

```bash
chmod +x setup_auditd_wazuh.sh
sudo ./setup_auditd_wazuh.sh

```

## ⚙️ ¿Qué hace el script?

El script automatiza el ciclo de vida completo de la configuración de auditoría en 5 pasos:

1. **Instalación:** Asegura que `auditd` y `audispd-plugins` estén instalados.
2. **Limpieza Profunda (Deep Clean):** - Elimina reglas antiguas en `/etc/audit/rules.d/`.
* Elimina archivos maestros compilados obsoletos (`audit.rules`) que suelen causar conflictos.


3. **Aplicación de Golden Master:** Escribe el archivo `00-wazuh-standard.rules` con la normativa de Ciberseguridad.
4. **Compilación y Recarga:**
* Ejecuta `augenrules`.
* Limpia la memoria del Kernel (`auditctl -D`) para evitar reglas "zombies".
* Recarga la configuración limpia.


5. **Validación:** Muestra en pantalla las reglas activas para confirmación visual inmediata.

## 📚 Cobertura de Reglas (Golden Master)

El set de reglas aplicado está diseñado para cumplir con **PCI-DSS 10.2** y **CIS Benchmark**, enfocándose en 4 pilares:

| Pilar de Seguridad | Archivos Monitoreados | Key (Wazuh Tag) | Descripción |
| --- | --- | --- | --- |
| **Identidad** | `/etc/passwd`, `/etc/shadow`, `/etc/group` | `identity` | Detecta creación de usuarios, cambios de contraseñas o escalada de privilegios local. |
| **Red y Sistema** | `/etc/hosts`, `/etc/network/`, `/etc/issue` | `system-locale` | Detecta modificaciones en resolución DNS local o configuración de interfaces de red. |
| **Privilegios** | `/etc/sudoers`, `/etc/sudoers.d/` | `scope` | Alerta crítica si alguien modifica quién puede ejecutar comandos como root. |
| **Integridad Tiempo** | `adjtimex`, `settimeofday` | `time-change` | Detecta intentos de manipular la hora del servidor para ocultar trazas forenses. |

## ✅ Validación

Al finalizar la ejecución, el script mostrará automáticamente el output de `auditctl -l`.
**Resultado esperado:** Una lista limpia de aprox. 15 reglas.

Ejemplo de salida correcta:

```text
-w /etc/passwd -p wa -k identity
-w /etc/hosts -p wa -k system-locale
...

```

*Si no aparecen reglas recursivas sobre `/etc` completo, la estandarización fue exitosa.*

## ✒️ Contribuciones y Autor

**Desarrollado por:** Carlos Valenzuela
**Rol:** Ingeniero de Ciberseguridad 
**Licencia:** Uso interno corporativo.

---

*Este proyecto es parte de la iniciativa de mejora continua del SOC.*
