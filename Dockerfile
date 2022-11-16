#syntax=docker/dockerfile:1.4
FROM ghcr.io/graalvm/graalvm-ce:22.2.0 as graalvm

# see: https://gitlab.alpinelinux.org/alpine/aports/-/issues/10136
# see: https://gitlab.com/pdftk-java/pdftk/-/blob/v3.3.3/build.gradle
RUN gu install native-image
WORKDIR /build
RUN curl https://gitlab.com/api/v4/projects/5024297/packages/generic/pdftk-java/v3.3.3/pdftk-all.jar --output pdftk-all.jar \
	&& curl https://gitlab.com/pdftk-java/pdftk/-/raw/v3.3.3/META-INF/native-image/reflect-config.json --output reflect-config.json \
	&& curl https://gitlab.com/pdftk-java/pdftk/-/raw/v3.3.3/META-INF/native-image/resource-config.json --output resource-config.json \
	&& native-image --static -jar pdftk-all.jar \
		-H:Name=pdftk \
		-H:ResourceConfigurationFiles='resource-config.json' \
		-H:ReflectionConfigurationFiles='reflect-config.json' \
		-H:GenerateDebugInfo=0


FROM scratch AS standalone-binary
COPY --from=graalvm /build/pdftk /pdftk

# This is defined as last target to be backward compatible with build without explicit --target option
FROM graalvm AS default
