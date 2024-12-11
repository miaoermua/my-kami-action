FROM node:20-alpine AS builder

RUN apk add --no-cache libc6-compat git
RUN npm i -g pnpm
WORKDIR /app
RUN git clone https://github.com/miaoermua/my-kami.git 

RUN cd my-kami && \
    pnpm install && \
    npm run build

# If using npm comment out above and use below instead
# RUN npm run build

# Production image, copy all the files and run next
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV BASE_URL=https://www.miaoer.net
ENV BASE_URL=${BASE_URL}
ENV NEXT_PUBLIC_API_URL=https://api.miaoer.net/api/v2
ENV NEXT_PUBLIC_GATEWAY_URL=https://api.miaoer.net
RUN node -e "console.log(process.env)"
# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# You only need to copy next.config.mjs if you are NOT using the default configuration
COPY --from=builder /app/my-kami/next.config.mjs ./
COPY --from=builder /app/my-kami/public ./public
COPY --from=builder /app/my-kami/package.json ./package.json

# Automatically leverage output traces to reduce image size 
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/my-kami/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/my-kami/.next/static ./.next/static

USER nextjs

EXPOSE 2323

ENV PORT 2323

CMD echo "Mix Space Web [Kami] Image." && node server.js
