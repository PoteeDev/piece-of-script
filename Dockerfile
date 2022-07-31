FROM alpine:3 AS build

# The Hugo version
ARG VERSION=0.92.2

ADD https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz /hugo.tar.gz
RUN tar -zxvf hugo.tar.gz
RUN /hugo version

# We add git to the build stage, because Hugo needs it with --enableGitInfo
RUN apk add --no-cache git

# The source files are copied to /site
COPY . /site
WORKDIR /site

# And then we just run Hugo
RUN /hugo --minify --enableGitInfo
RUN ls -la public

# stage 2
FROM nginx:1.15-alpine

WORKDIR /usr/share/nginx/html/

# Clean the default public folder
RUN rm -fr * .??*

# This inserts a line in the default config file, including our file "expires.inc"
# RUN sed -i '9i\        include /etc/nginx/conf.d/expires.inc;\n' /etc/nginx/conf.d/default.conf

# # The file "expires.inc" is copied into the image
# COPY _docker/expires.inc /etc/nginx/conf.d/expires.inc
# RUN chmod 0644 /etc/nginx/conf.d/expires.inc

# Finally, the "public" folder generated by Hugo in the previous stage
# is copied into the public fold of nginx
COPY --from=build /site/public /usr/share/nginx/html