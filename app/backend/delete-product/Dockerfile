FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install --production
COPY index.js .
EXPOSE 3004
CMD ["node", "index.js"]

# 2026 - Disenador asignatura: Ignacio A. Pastenet M.
