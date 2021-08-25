FROM python:3.9.6-slim-buster

# Project files
ARG PROJECT_DIR=/app
ARG DATA_DIR=/app
RUN mkdir -p $PROJECT_DIR
RUN mkdir -p $DATA_DIR

WORKDIR $PROJECT_DIR

# Add dependencies for Python package pyodbc and for Hortonworks Hive ODBC driver
RUN apt-get update \
    && apt-get install -y g++ unixodbc unixodbc-dev \
    && apt-get install -y libsasl2-modules-gssapi-mit libsasl2-modules

# Copy drivers and scripts
COPY . /app

# Copy ODBC configuration file
COPY odbcinst.ini /etc

# Install Cloudera Hive ODBC driver
RUN dpkg -i /app/drivers/clouderahiveodbc_2.5.25.1020-2_amd64.deb

# Install FreeTDS ODBC driver for Microsoft SQL Server
RUN apt-get install -y tdsodbc

# Install Hortonworks Hive ODBC driver
RUN dpkg -i /app/drivers/hive-odbc-native_2.6.1.1001-2_amd64.deb

# Install MySQL ODBC driver
RUN tar xvzf /app/drivers/mysql-connector-odbc-8.0.12-linux-debian9-x86-64bit.tar.gz \
    && cp ./mysql-connector-odbc-8.0.12-linux-debian9-x86-64bit/lib/libmyodbc8* /usr/lib/x86_64-linux-gnu/odbc/ \
    && rm -R ./mysql-connector-odbc-8.0.12-linux-debian9-x86-64bit

# Install Oracle ODBC driver
RUN apt-get install -y alien libaio1 \
    && alien -i /app/drivers/oracle-instantclient12.2-*
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/12.2/client64/lib

# Add PostgreSQL ODBC driver
RUN apt-get install -y odbc-postgresql

# Install Snowflake ODBC driver
RUN dpkg -i /app/drivers/snowflake-odbc-2.20.4.x86_64.deb

# Install Teradata ODBC driver
RUN apt-get install -y lib32stdc++6 \
    && tar xvzf /app/drivers/tdodbc1620__ubuntu_indep.16.20.00.36-1.tar.gz \
    && dpkg -i ./tdodbc1620/tdodbc1620-16.20.00.36-1.noarch.deb \
    && rm -R ./tdodbc1620

# Install SQL Server driver
ENV ACCEPT_EULA=Y
RUN apt-get install -y --no-install-recommends gcc g++ gnupg
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends --allow-unauthenticated msodbcsql17 mssql-tools \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc


# Deleting drivers packages
RUN rm -rf /app/drivers

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r requirements.txt


ENV FLASK_APP=service.py

CMD flask run -h 0.0.0.0 -p 5000
