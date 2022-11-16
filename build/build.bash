#!/usr/bin/env bash

package=$1
if [[ -z "$package" ]]; then
  echo "usage: $0 <package-name> <version>"
  exit 1
fi

version=$2
if [[ -z "$version" ]]; then
  echo "usage: $0 <package-name> <version>"
  exit 1
fi

platforms=()
while IFS= read -r line || [[ "$line" ]]; do
  platforms+=("$line")
done < build/platforms.txt

for platform in "${platforms[@]}"
do
        platform_split=(${platform//\// })
        GOOS=${platform_split[0]}
        GOARCH=${platform_split[1]}
        output_name=$package'-'$version'-'$GOOS'-'$GOARCH
        if [ "$GOOS" = "windows" ]; then
                output_name+='.exe'
        fi
        echo -e "\n\tBuilding $platform\n"
        env CGO_ENABLED=0 GOOS="$GOOS" GOARCH="$GOARCH" go build -v -a -ldflags '-w' -o /tmp/"$output_name" ./*.go
        if [ $? -ne 0 ]; then
                echo 'An error has occurred! Aborting the script execution...'
                exit 1
        fi
done
