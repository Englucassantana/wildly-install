# Use Red Hat UBI 8 as base image
FROM redhat/ubi8:latest

# Set environment variables
ENV WILDFLY_VERSION=13.0.0.Final \
    WILDFLY_HOME=/opt/wildfly \
    WILDFLY_LOG_DIR=/app/logs/wildfly \
    JBOSS_USER=rdc_userapp \
    JBOSS_PASSWORD=rdc123

# Set root password
RUN echo "root:${JBOSS_PASSWORD}" | chpasswd

# Install necessary packages
RUN dnf install -y java-1.8.0-openjdk wget unzip && \
    dnf clean all

# Create application user
RUN useradd -m ${JBOSS_USER}

# Create directories
RUN mkdir -p ${WILDFLY_HOME} ${WILDFLY_LOG_DIR} && \
    chown -R ${JBOSS_USER}:${JBOSS_USER} /app/logs /opt

# Download and extract WildFly
WORKDIR /tmp
RUN wget https://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.zip && \
    unzip wildfly-${WILDFLY_VERSION}.zip && \
    mv wildfly-${WILDFLY_VERSION}/* ${WILDFLY_HOME} && \
    rm -rf wildfly-${WILDFLY_VERSION}*

# Set WildFly log path (example, you may need additional configs)
RUN sed -i "s|<periodic-rotating-file-handler.*|<periodic-rotating-file-handler name=\"FILE\" autoflush=\"true\"> <file relative-to=\"jboss.server.log.dir\" path=\"server.log\"/> <suffix value=\".yyyy-MM-dd\"/> <append value=\"true\"/> </periodic-rotating-file-handler>|g" \
    ${WILDFLY_HOME}/standalone/configuration/standalone.xml

# Change permissions and set working directory
RUN chown -R ${JBOSS_USER}:${JBOSS_USER} ${WILDFLY_HOME}

USER ${JBOSS_USER}
WORKDIR ${WILDFLY_HOME}/bin

# Expose default WildFly port
EXPOSE 8080

# Default command to start WildFly
# CMD ["./standalone.sh", "-b", "0.0.0.0"]
