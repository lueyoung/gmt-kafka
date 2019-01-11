FROM zookeeper:3.4
COPY ./scripts/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
