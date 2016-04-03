# Elasticsearch: Analytics database
ExternalProject_Add(
  elasticsearch
  URL https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
  URL_HASH SHA1=${ELASTICSEARCH_HASH}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND rsync -a <SOURCE_DIR>/ ${STAGE_EMBEDDED_DIR}/elasticsearch/
    COMMAND cd ${STAGE_EMBEDDED_DIR}/bin && ln -snf ../elasticsearch/bin/plugin ./plugin
    COMMAND cd ${STAGE_EMBEDDED_DIR}/bin && ln -snf ../elasticsearch/bin/elasticsearch ./elasticsearch
)