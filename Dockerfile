FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS builder

RUN apk add --no-cache wget unzip make

WORKDIR /app
COPY . .

# deps downloads prebuilt WASM bundles
# asm-jars downloads ASM jars
# build compiles ikvmc + dotnet publish -> frontend/public/
RUN make deps asm-jars build

FROM nginx:alpine
COPY --from=builder /app/frontend/public /usr/share/nginx/html
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]