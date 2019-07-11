FROM mysql:5.7

# Add a database
ENV MYSQL_DATABASE cec

# Set root passwd
ENV MYSQL_ROOT_PASSWORD root

# Add a new user
ENV MYSQL_USER=cec
ENV MYSQL_PASSWORD=cec

# EXPOSE 3306

# Add the content of the sql-scripts/ directory to your image
# All scripts in docker-entrypoint-initdb.d/ are automatically
# executed during container startup
COPY ./sql-scripts/ /docker-entrypoint-initdb.d