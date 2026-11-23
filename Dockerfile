# ---- Build do frontend ----
FROM node:24-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY frontend/package.json frontend/package-lock.json ./frontend/
RUN npm --prefix frontend ci

COPY frontend ./frontend
RUN npm --prefix frontend run build

# ---- Runtime (API + arquivos estáticos) ----
FROM node:24-alpine
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=80

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY src ./src
COPY --from=build /app/frontend/dist ./public

RUN mkdir -p /app/data

EXPOSE 80

CMD ["node", "src/server.js"]
