ARG VPL_BASE_DISTRO=debian

FROM ${VPL_BASE_DISTRO}

USER root:root

# Crea el entorno jail vacío
RUN mkdir -p /opt/vpl-jail/jail

# Set default install levels: minimum < basic < standard < full
ARG VPL_INSTALL_LEVEL=full
ARG VPL_JAIL_JAILPATH=/
ARG VPL_JAIL_PORT=80
ARG VPL_JAIL_SECURE_PORT=0
ARG VPL_CERTIFICATES_DIR=/etc/vpl/ssl
ARG VPL_JAIL_SSL_CERT_FILE="${VPL_CERTIFICATES_DIR}/fullchain.pem"
ARG VPL_JAIL_SSL_KEY_FILE="${VPL_CERTIFICATES_DIR}/privkey.pem"

# Recibir el puerto de Google Cloud Run o usar el valor por defecto 8080
ENV VPL_JAIL_PORT=${PORT:-8080}
ENV VPL_JAIL_JAILPATH=${VPL_JAIL_JAILPATH}
ENV VPL_JAIL_SECURE_PORT=${VPL_JAIL_SECURE_PORT}
ENV VPL_CERTIFICATES_DIR="${VPL_CERTIFICATES_DIR}"
ENV VPL_JAIL_SSL_CERT_FILE="${VPL_JAIL_SSL_CERT_FILE}"
ENV VPL_JAIL_SSL_KEY_FILE="${VPL_JAIL_SSL_KEY_FILE}"

# Copy installer
COPY . /vpl-jail-system
WORKDIR /vpl-jail-system

# Install bash on distros with no bash
RUN /vpl-jail-system/install-bash-sh

# Run VPL installer
RUN /vpl-jail-system/install-vpl-sh noninteractive ${VPL_INSTALL_LEVEL}

# Remove installer
WORKDIR /
RUN rm -R vpl-jail-system

VOLUME [ "${VPL_CERTIFICATES_DIR}" ]

# Exponer el puerto configurado por la variable PORT o 8080 por defecto
EXPOSE ${VPL_JAIL_PORT}

STOPSIGNAL SIGTERM

CMD ["/usr/sbin/vpl/vpl-jail-system", "start_foreground"]
