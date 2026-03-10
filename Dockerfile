###########################################################
# Dockerfile that builds a Project Zomboid Gameserver
###########################################################

# [PODMAN FIX] Registro completo para evitar el error "short-name did not resolve"
FROM docker.io/cm2network/steamcmd:root

LABEL maintainer="daniel.carrasco@electrosoftcloud.com"

ENV STEAMAPPID=380870
ENV STEAMAPP=pz
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-dedicated"

# Fix for a new installation problem in the Steamcmd client
ENV HOME="${HOMEDIR}"

# Receive the value from podman-compose / docker-compose as an ARG
ARG STEAMAPPBRANCH="public"

# Promote the ARG value to an ENV for runtime
ENV STEAMAPPBRANCH=$STEAMAPPBRANCH

# Install required packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends --no-install-suggests \
  dos2unix \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Generate locales to allow other languages in the PZ Server
RUN sed -i 's/^# *\(es_ES.UTF-8\)/\1/' /etc/locale.gen \
  # Generate locale
  && locale-gen

# Download the Project Zomboid dedicated server app using the steamcmd app
# [PODMAN FIX] En Podman rootless, chown dentro del build puede fallar si el USER
# del contenedor no tiene uid mapeado. Se añade --no-cache para evitar problemas
# de capas al cambiar de Docker a Podman.
RUN set -x \
  && mkdir -p "${STEAMAPPDIR}" \
  && chown -R "${USER}:${USER}" "${STEAMAPPDIR}" \
  && bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
  +login anonymous \
  +app_update "${STEAMAPPID}" -beta "${STEAMAPPBRANCH}" validate \
  +quit

# Copy the entry point file
# [PODMAN FIX] --chown en COPY funciona en Podman solo si el usuario existe
# en el contenedor. cm2network/steamcmd:root define USER=root, asi que es seguro.
COPY --chown=${USER}:${USER} scripts/entry.sh /server/scripts/entry.sh
RUN chmod 550 /server/scripts/entry.sh

# Copy searchfolder file
COPY --chown=${USER}:${USER} scripts/search_folder.sh /server/scripts/search_folder.sh
RUN chmod 550 /server/scripts/search_folder.sh

# Create required folders to keep their permissions on mount
RUN mkdir -p "${HOMEDIR}/Zomboid"

WORKDIR ${HOMEDIR}

# Expose ports
# [PODMAN FIX] En Podman rootless, puertos < 1024 requieren configuracion extra.
# 16261, 16262 y 27015 están bien al ser > 1024, no hay problema aquí.
EXPOSE 16261-16262/udp \
  27015/tcp

ENTRYPOINT ["/server/scripts/entry.sh"]