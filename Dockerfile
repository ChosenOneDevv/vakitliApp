FROM nginx:alpine

# Copy the contents of the docs directory to the Nginx HTML directory
COPY ./docs /usr/share/nginx/html

# Copy privacy-policy.html as index.html so the root URL also serves the privacy policy
RUN cp /usr/share/nginx/html/privacy-policy.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
