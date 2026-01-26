FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .


FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app .
EXPOSE 3000
CMD ["node", "src/index.js"]

#Usei o multi-stage para deixar a imagem menor levando apenas oq é preciso para rodar a aplicação hipotética