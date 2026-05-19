FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS builder

RUN apk add --no-cache wget unzip make

WORKDIR /app
COPY . .

# deps downloads prebuilt WASM bundles
# asm-jars downloads ASM jars
# build compiles ikvmc + dotnet publish
# publish runs pnpm build for the frontend
RUN make deps asm-jars build publish

FROM nginx:alpine
COPY --from=builder /app/frontend/dist /usr/share/nginx/html
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]