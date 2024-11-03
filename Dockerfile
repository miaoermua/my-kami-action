# Rebuild the source code only when needed
FROM node:18-alpine 

RUN apk add libc6-compat git && \
    npm i -g pnpm pm2

WORKDIR /app
RUN git clone https://github.com/miaoermua/kami.git --depth 1 .
ENV BASE_URL=https://www.miaoer.net
ENV NEXT_PUBLIC_API_URL=https://api.miaoer.net/api/v2
ENV NEXT_PUBLIC_GATEWAY_URL=https://api.miaoer.net
RUN node -e "console.log(process.env)" && \
    pnpm install && \
    npm run build

EXPOSE 2323

ENV PORT 2323


CMD echo "Mix Space Web [Kami] Image." && sh
