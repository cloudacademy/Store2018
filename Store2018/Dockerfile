FROM jeremycookdev/microservicebase:latest AS base
COPY nginx.conf /etc/nginx/sites-available/default
COPY cert.pem /etc/nginx/conf.d/cert.pem
COPY key.pem /etc/nginx/conf.d/key.pem
WORKDIR /app
ENV ASPNETCORE_URLS http://+:8000
EXPOSE 8000

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src/Store2018
COPY ./Store2018.csproj .

RUN dotnet restore -nowarn:msb3202,nu1503
COPY . .
RUN pwd
RUN ls -la
RUN dotnet build -c Release -o /app

FROM build AS publish
RUN dotnet publish -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord"]