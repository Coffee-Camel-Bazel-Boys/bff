FROM perl:latest
EXPOSE 3000
COPY . /bff
WORKDIR /bff
RUN cpan Mojolicious
CMD ["perl", "bff.pl", "prefork", "-m", "production"]
