# Blog

docker build -t blog_prod .

docker run --env-file .env -p 8080:4000 blog_prod
