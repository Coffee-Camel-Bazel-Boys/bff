FROM perl:latest AS mojo
RUN cpan Mojolicious

FROM mojo AS bff
EXPOSE 3000
COPY . /bff
WORKDIR /bff
CMD ["perl", "bff.pl", "prefork", "-m", "production"]
