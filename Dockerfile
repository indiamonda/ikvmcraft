FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends wget unzip make bash python3 curl ca-certificates gnupg && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g pnpm && npm install -g tsx && \
    pnpm config set enable-pre-post-scripts true && \
    pnpm config set ignore-scripts false && \
    pnpm config set scripts-prepend-node-path true && \
    echo "y" | pnpm approve-builds && \
    dotnet workload install wasm-tools

WORKDIR /app
COPY . .

RUN cd frontend && echo 'ignore-scripts=false' > .npmrc && echo 'confirmModulesPurge=false' >> .npmrc && CI=true pnpm install && pnpm add -D tsx

# deps downloads prebuilt WASM bundles
# asm-jars downloads ASM jars
# build compiles ikvmc + dotnet publish -> frontend/public/
RUN make deps asm-jars build publish

FROM nginx:alpine
COPY --from=builder /app/frontend/public /usr/share/nginx/html
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]