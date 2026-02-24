FROM bash:5.2

WORKDIR /app

COPY handler.sh /app/handler.sh
RUN chmod +x /app/handler.sh

CMD ["/app/handler.sh"]
