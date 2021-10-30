FROM elixir:1.12.3-alpine AS build

RUN apk add --no-cache build-base npm git py-pip libstdc++6

WORKDIR /blog

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=bKiHGhK/L/x4Pxt7+XMMAZ5W68lLsOloqH3qYXYChW+UanH6jiKtD8EQbYeFtG6Y
ENV DATABASE_URL=ecto://postgres:postgres@postgres/blog_prod

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

COPY lib lib
RUN mix do compile, release

FROM alpine:3.9 AS blog
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /blog

RUN chown nobody:nobody /blog

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /blog/_build/prod/rel/blog ./

ENV HOME=/blog

CMD ["bin/blog", "start"]
