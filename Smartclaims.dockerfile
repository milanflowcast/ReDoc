# To run:
# docker build -t sc-api-docs -f Smartclaims.dockerfile .
# docker run -it --rm -p 80:80 sc-api-docs

FROM node:alpine

RUN apk update && apk add --no-cache git 

# generate bundle
WORKDIR /build
COPY . /build
RUN yarn install --frozen-lockfile --ignore-optional --ignore-scripts
RUN npm run bundle:standalone

FROM nginx:alpine

ENV PAGE_TITLE="Smartclaims API Reference"
ENV PAGE_FAVICON="favicon.ico"
ENV SPEC_URL="smartclaims.yaml"
ENV PORT=80
ENV REDOC_OPTIONS="hide-loading path-in-middle-panel"

# copy files to the nginx folder
COPY --from=0 build/bundles /usr/share/nginx/html
COPY config/docker/index.tpl.html /usr/share/nginx/html/index.html
COPY flowcast/favicon.ico /usr/share/nginx/html/
COPY flowcast/smartclaims.yaml /usr/share/nginx/html/
COPY config/docker/nginx.conf /etc/nginx/
COPY config/docker/docker-run.sh /usr/local/bin

EXPOSE 80

CMD ["sh", "/usr/local/bin/docker-run.sh"]
