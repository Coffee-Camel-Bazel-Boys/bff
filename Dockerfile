FROM perl:latest AS build
EXPOSE 3000
COPY . /bff
WORKDIR /bff
RUN cpan Mojolicious

FROM build AS bff
CMD ["perl", "bff.pl", "daemon", "-m", "production"]
