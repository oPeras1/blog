FROM node:22-alpine AS build
WORKDIR /app

RUN npm install -g pnpm@9

COPY package.json pnpm-lock.yaml* .npmrc* ./
RUN pnpm install

COPY . .

RUN rm -f pnpm-workspace.yaml

RUN pnpm build
RUN pnpm postbuild 

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
