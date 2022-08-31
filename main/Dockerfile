FROM ubuntu:18.04
RUN apt update
RUN apt -y install nginx
EXPOSE 80
ADD index.html /var/www/html/index.html

CMD ["nginx", "-g", "daemon off;"]
